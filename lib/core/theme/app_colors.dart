import 'package:flutter/material.dart';

/// ALU official color palette for the Student Assistant app.
class AppColors {
  AppColors._();

  /// Dark blue primary background
  static const Color background = Color(0xFF0D1B2A);

  /// Slightly lighter dark blue for secondary surfaces
  static const Color backgroundSecondary = Color(0xFF1B263B);

  /// Primary text color
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary/muted text
  static const Color textSecondary = Color(0xFFB0BEC5);

  /// Yellow accent for buttons, selected tabs, and interactive elements
  static const Color accent = Color(0xFFFFC300);

  /// Alternative yellow for hover/active states
  static const Color accentAlt = Color(0xFFF4D03F);

  /// Red for warnings and risk indicators (e.g., attendance below 75%)
  static const Color warning = Color(0xFFE74C3C);

  /// Darker red for critical states
  static const Color warningDark = Color(0xFFC0392B);

  /// White for cards and content blocks
  static const Color card = Color(0xFFFFFFFF);

  /// Light gray for card backgrounds (alternative)
  static const Color cardAlt = Color(0xFFF8F9FA);
}
