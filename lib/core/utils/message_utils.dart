import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MessageUtils {
  static void showMessage({
    required BuildContext context,
    required String title,
    bool? error,
    int duration = 2,
  }) {
    Color backgroundColor;

    if (error == null) {
      backgroundColor = AppColors.textSecondary; // Grey for neutral messages
    } else if (error) {
      backgroundColor = AppColors.error; // Red for errors
    } else {
      backgroundColor = AppColors.success; // Green for success
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
