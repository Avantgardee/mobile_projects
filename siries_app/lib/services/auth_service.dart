import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_dto.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;

  String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Требуется повторный вход.';
      case 'unverified-email':
        return 'Email не подтвержден.';
      case 'invalid-email':
        return 'Некорректный email.';
      case 'user-disabled':
        return 'Пользователь заблокирован.';
      case 'user-not-found':
        return 'Пользователь не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'email-already-in-use':
        return 'Email уже зарегистрирован.';
      case 'weak-password':
        return 'Слишком слабый пароль.';
      case 'operation-not-allowed':
        return 'Операция не разрешена. Обратитесь к администратору.';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Повторите позже.';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету.';
      default:
        return 'Ошибка аутентификации: ${e.message ?? 'Неизвестная ошибка.'}';
    }
  }

  Future<User?> registerUser(String email, String password, String firstName, String lastName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user!.sendEmailVerification();
      final userId = userCredential.user!.uid;
      final userDto = UserDto(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        emailVerified: false,
        regDate: DateTime.now().toIso8601String(),
      );
      await _firestore.collection('users').doc(userId).set(userDto.toMap());

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmailVerifiedStatus(String userId, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'emailVerified': isVerified,
      });
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } on FirebaseException catch (e) {
      throw Exception('Ошибка при обновлении данных в Firestore: ${e.message ?? 'Неизвестная ошибка.'}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
