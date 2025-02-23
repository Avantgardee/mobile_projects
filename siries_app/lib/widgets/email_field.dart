import 'package:flutter/material.dart';

class EmailField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(bool) onValidationChanged;

  const EmailField({
    Key? key,
    required this.controller,
    required this.onValidationChanged,
  }) : super(key: key);

  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateEmail);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateEmail);
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _validateEmail() {
    setState(() {
      final email = widget.controller.text;
      if (email.isEmpty || !_isValidEmail(email)) {
        _errorText = 'Пожалуйста, введите корректный email';
        widget.onValidationChanged(true);
      } else {
        _errorText = null;
        widget.onValidationChanged(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
