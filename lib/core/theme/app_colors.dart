import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Based on exact Figma Design
  static const Color primary = Color(0xFF4A5568); // Dark navy blue from Figma
  static const Color primaryLight = Color(0xFF6B7280); // Light gray
  static const Color primaryDark = Color(0xFF2D3748); // Darker navy

  // Card Background Colors
  static const Color loginCardBg =
      Color(0xFF4A5568); // Dark grayish blue from login card
  static const Color cardBackground = Colors.white;
  static const Color accentYellow =
      Color(0xFFFFC107); // Yellow accent for register

  // Background Colors
  static const Color background = Colors.white;
  // Color(0xFFE5E5E5); // Light gray background from Figma
  static const Color scaffoldBackground = Colors.white;
  // Color(0xFFE5E5E5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark text
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color textLight = Color(0xFF9CA3AF); // Light gray text
  static const Color textWhite = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange

  // Transaction Colors
  static const Color income = Color(0xFF10B981); // Green for income
  static const Color expense = Color(0xFFEF4444); // Red for expense

  // Border Colors
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFF3F4F6);

  // Shadow
  static const Color shadowColor = Color(0x0A000000);

  // Bottom Navigation
  static const Color bottomNavBg = Colors.white;
  static const Color bottomNavSelected = Color(0xFF5B6ACF);
  static const Color bottomNavUnselected = Color(0xFF9CA3AF);

  // Gradient for account cards
  static const LinearGradient accountCardGradient = LinearGradient(
    colors: [Color(0xFF6B7EFF), Color(0xFF9CA8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Header gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}