import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import '../widgets/verification_dialog.dart'; // Импортируем компонент с модалкой

class EmailVerificationScreen extends StatefulWidget {
  final User user;

  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResent = false;

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.isEmailVerified();
      final userProf = _authService.currentUser;
      if (userProf?.emailVerified ?? false) {
        await _authService.updateEmailVerifiedStatus(widget.user.uid, true);
        VerificationDialog.showVerificationDialog(context, 'Email подтвержден!', isInfo: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        VerificationDialog.showVerificationDialog(context, 'Email еще не подтвержден.');
      }
    } catch (e) {
      VerificationDialog.showVerificationDialog(context, 'Ошибка: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.user.sendEmailVerification();
      setState(() {
        _isResent = true;
      });
      VerificationDialog.showVerificationDialog(context, 'Письмо с подтверждением отправлено повторно.', isInfo: true);
    } catch (e) {
      VerificationDialog.showVerificationDialog(context, 'Ошибка: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToAuthScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение Email')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Пожалуйста, подтвердите ваш email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (_isResent)
              const Text(
                'Письмо с подтверждением было отправлено повторно.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _checkEmailVerification,
                    child: const Text('Проверить подтверждение'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resendVerificationEmail,
                    child: const Text('Отправить код повторно'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _goToAuthScreen,
                    child: const Text('Вернуться на вход/регистрацию'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}