import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> getAverageRating(String recipeId) async {
    final recipeDoc = await _firestore.collection('recipes').doc(recipeId).get();
    return (recipeDoc.data()?['rating'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> rateRecipe(String userId, String recipeId, int newRating) async {
    final ratingsRef = _firestore.collection('ratings');
    final recipeRef = _firestore.collection('recipes').doc(recipeId);

    await _firestore.runTransaction((transaction) async {
      final ratingDoc = await ratingsRef
          .where('userId', isEqualTo: userId)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      int oldRating = 0;
      bool isNewRating = ratingDoc.docs.isEmpty;

      if (!isNewRating) {
        oldRating = ratingDoc.docs.first.data()['rating'] as int;
      }

      if (isNewRating) {
        await ratingsRef.add({
          'userId': userId,
          'recipeId': recipeId,
          'rating': newRating,
        });
      } else {
        await ratingsRef.doc(ratingDoc.docs.first.id).update({
          'rating': newRating,
        });
      }

      final recipeDoc = await transaction.get(recipeRef);
      final currentSum = recipeDoc.data()?['sumRatings'] ?? 0;
      final currentTotal = recipeDoc.data()?['totalRatings'] ?? 0;

      int newSum = currentSum - oldRating + newRating;
      int newTotal = isNewRating ? currentTotal + 1 : currentTotal;

      double newAverage = newSum / newTotal;

      transaction.update(recipeRef, {
        'sumRatings': newSum,
        'totalRatings': newTotal,
        'rating': newAverage,
      });
    });
  }
}
