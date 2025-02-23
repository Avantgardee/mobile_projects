import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(String userId, String recipeId, String text) async {
    await _firestore.collection('reviews').add({
      'userId': userId,
      'recipeId': recipeId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviews(String recipeId) {
    return _firestore
        .collection('reviews')
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
