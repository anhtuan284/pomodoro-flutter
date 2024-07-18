import 'package:flutter/material.dart';

enum MessageType { success, warning, error, info }

void showMessage({
  required BuildContext context,
  required String title,
  required String message,
  required MessageType type,
}) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case MessageType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case MessageType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case MessageType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case MessageType.info:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    duration: const Duration(seconds: 2),
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ));
}
