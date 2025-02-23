import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_dto.dart';
import '../models/recipe_dto.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserDto?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserDto.fromFirestore(userDoc.data() as Map<String, dynamic>, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserDto?> getUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserDto.fromFirestore(userDoc.data() as Map<String, dynamic>, currentUser.uid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserDto userDto) async {
    try {
      await _firestore.collection('users').doc(userDto.id).update(userDto.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      await _firestore.collection('users').doc(currentUser.uid).delete();
      await currentUser.delete();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavoriteRecipe(RecipeDto recipe) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('Профиль пользователя не найден');
      }

      List<String> favoriteRecipes = List<String>.from(userDoc['favoriteRecipes'] ?? []);

      if (favoriteRecipes.contains(recipe.id)) {
        favoriteRecipes.remove(recipe.id);
      } else {
        favoriteRecipes.add(recipe.id);
      }

      await _firestore.collection('users').doc(currentUser.uid).update({
        'favoriteRecipes': favoriteRecipes,
      });
    } catch (e) {
      rethrow;
    }
  }
}
