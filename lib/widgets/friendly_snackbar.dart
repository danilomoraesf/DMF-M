import 'package:flutter/material.dart';

void showFriendlySnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.info_outline,
  Duration duration = const Duration(seconds: 3),
  bool isError = false,
  bool isSuccess = false,
}) {
  final theme = Theme.of(context);
  final Color bgColor;
  final Color fgColor;

  if (isError) {
    bgColor = Colors.red.shade100;
    fgColor = Colors.red.shade800;
    icon = Icons.error_outline;
  } else if (isSuccess) {
    bgColor = Colors.green.shade100;
    fgColor = Colors.green.shade800;
    icon = Icons.check_circle_outline;
  } else {
    bgColor = theme.colorScheme.primaryContainer;
    fgColor = theme.colorScheme.onPrimaryContainer;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fgColor, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
    ),
  );
}
