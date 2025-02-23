import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(bool) onValidationChanged;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.onValidationChanged,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;
  String? _errorText;

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _validatePassword() {
    setState(() {
      final password = widget.controller.text;
      if (password.isEmpty || !_isValidPassword(password)) {
        _errorText = 'Пароль должен быть не менее 6 символов';
        widget.onValidationChanged(true);
      } else {
        _errorText = null;
        widget.onValidationChanged(false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validatePassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validatePassword);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Пароль',
        errorText: _errorText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }
}
