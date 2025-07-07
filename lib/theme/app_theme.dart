import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Tajawal',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontFamily: 'Tajawal',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamily: 'Tajawal',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      dividerColor: Colors.grey.shade200,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: Colors.grey.shade900,
        background: AppColors.darkBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          fontFamily: 'Tajawal',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.darkTextPrimary,
          fontFamily: 'Tajawal',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade400,
          fontFamily: 'Tajawal',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade900,
      ),
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      dividerColor: Colors.grey.shade800,
    );
  }

  static ThemeData getDarkThemeAlt() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: Colors.grey.shade900,
        background: AppColors.darkBackground,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade900,
      ),
      // ... بقية الإعدادات
    );
  }
}
