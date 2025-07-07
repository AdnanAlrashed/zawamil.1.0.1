import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const primary = Color(0xFF1E3A8A);
  static const secondary = Color(0xFFF59E0B);
  static const accent = Color(0xFF10B981);
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const cardColor = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const darkPrimary = Color(0xFF2563EB);
  static const darkSecondary = Color(0xFFF59E0B);
  static const darkBackground = Color(0xFF121212);
  static const darkTextPrimary = Color(0xFFE1E1E1);
  static const darkCardColor = Color(0xFF1E1E1E);

  // Common Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Get appropriate color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardColor
        : cardColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }
}
