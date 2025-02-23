import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String errorMessage;
  final void Function(bool) onValidationChanged;
  final bool enableValidation;
  final bool isReadOnly;
  final String? pattern;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.onValidationChanged,
    this.errorMessage = "Проверьте корректность данных",
    this.enableValidation = false,
    this.isReadOnly = false,
    this.pattern,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    if (!widget.enableValidation) {
      setState(() => _errorText = null);
      widget.onValidationChanged(false);
      return;
    }

    final text = widget.controller.text;

    setState(() {
      if (text.isEmpty) {
        _errorText = widget.errorMessage;
        widget.onValidationChanged(true);
        return;
      }

      if (widget.pattern != null && !RegExp(widget.pattern!).hasMatch(text)) {
        _errorText = widget.errorMessage;
        widget.onValidationChanged(true);
        return;
      }

      _errorText = null;
      widget.onValidationChanged(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: widget.isReadOnly,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
