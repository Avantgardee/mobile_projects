import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'list_page.dart';
import 'email_verification_screen.dart';
import '../widgets/password_field.dart';
import '../widgets/email_field.dart';
import '../widgets/verification_dialog.dart';
import '../widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  final Map<String, bool> _loginFieldErrors = {
    'email': false,
    'password': false,
  };

  final Map<String, bool> _registerFieldErrors = {
    'email': false,
    'password': false,
    'firstName': false,
    'lastName': false,
  };

  Map<String, bool> get _currentFieldErrors {
    return _isLogin ? _loginFieldErrors : _registerFieldErrors;
  }

  void _updateFieldError(String field, bool isInvalid) {
    if (_currentFieldErrors[field] != isInvalid) {
      setState(() {
        _currentFieldErrors[field] = isInvalid;
      });
    }
  }

  void _resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();

    setState(() {
      _currentFieldErrors.updateAll((key, value) => false);
    });
  }

  bool get _isInvalidData {
    return _currentFieldErrors.values.any((error) => error);
  }

  Future<void> _authenticate() async {
    if (_isInvalidData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final user = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user == null) return;

        await _authService.isEmailVerified();
        final userProf = _authService.currentUser;
        if (userProf?.emailVerified ?? false) {
          await _authService.updateEmailVerifiedStatus(user.uid, true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ListPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(user: user),
            ),
          );
        }
      } else {
        final user = await _authService.registerUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(user: user),
            ),
          );
        }
      }
    } on String catch (errorMessage) {
      VerificationDialog.showVerificationDialog(context, errorMessage);
    } catch (e) {
      VerificationDialog.showVerificationDialog(
          context, 'Произошла ошибка: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Вход' : 'Регистрация'),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        _isLogin ? Icons.restaurant_menu : Icons.account_circle_rounded,
                        size: 100,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      if (!_isLogin) ...[
                        CustomTextField(
                          controller: _lastNameController,
                          label: 'Фамилия',
                          errorMessage: 'Пожалуйста, введите вашу фамилию',
                          onValidationChanged: (isInvalid) => _updateFieldError('lastName', isInvalid),
                          enableValidation: true,
                          pattern: r'^.{4,}$',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _firstNameController,
                          label: 'Имя',
                          errorMessage: 'Пожалуйста, введите ваше имя',
                          onValidationChanged: (isInvalid) => _updateFieldError('firstName', isInvalid),
                          enableValidation: true,
                          pattern: r'^.{4,}$',
                        ),
                        const SizedBox(height: 16),
                      ],
                      EmailField(
                        controller: _emailController,
                        onValidationChanged: (isInvalid) => _updateFieldError('email', isInvalid),
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _passwordController,
                        onValidationChanged: (isInvalid) => _updateFieldError('password', isInvalid),
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _isInvalidData ? null : _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isInvalidData ? Colors.grey : Colors.yellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            _isLogin ? 'Войти' : 'Зарегистрироваться',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          _resetForm();
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт? Войти',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
