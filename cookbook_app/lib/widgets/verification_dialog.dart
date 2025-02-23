import 'package:flutter/material.dart';

class VerificationDialog extends StatelessWidget {
  final String message;
  final bool? isInfo;

  const VerificationDialog({
    super.key,
    required this.message,
    this.isInfo,
  });

  static void showVerificationDialog(
      BuildContext context,
      String message, {
        bool isInfo = false,
      }) {
    showDialog(
      context: context,
      builder: (ctx) => VerificationDialog(
        message: message,
        isInfo: isInfo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (isInfo ?? false)
                ? SizedBox.shrink()
                : const Text(
              'Ошибка',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isInfo == true ? Colors.black : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ОК'),
            ),
          ],
        ),
      ),
    );
  }
}
