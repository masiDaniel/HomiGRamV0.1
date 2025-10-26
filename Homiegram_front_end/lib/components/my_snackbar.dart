import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning }

void showCustomSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.success,
}) {
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xFF126E06);
      break;
    case SnackBarType.error:
      backgroundColor = const Color.fromARGB(255, 199, 4, 4);
      break;
    case SnackBarType.warning:
      backgroundColor = const Color.fromARGB(255, 255, 157, 0);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}
