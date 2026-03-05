import 'package:flutter/material.dart';

class AppColors {
  static const darkGreen   = Color(0xFF2C4A3E);
  static const midGreen    = Color(0xFF3D6B5C);
  static const sageGreen   = Color(0xFF8FA888);
  static const lightSage   = Color(0xFFB8CDB5);
  static const cream       = Color(0xFFF0EDE6);
  static const cardCream   = Color(0xFFF5F2EB);
  static const gold        = Color(0xFFC8A96E);
  static const goldLight   = Color(0xFFE8D5A3);
  static const textDark    = Color(0xFF1A2E27);
  static const textMuted   = Color(0xFF6B8C7D);
  static const white       = Color(0xFFFFFFFF);
  static const safeGreen   = Color(0xFF4CAF50);
  static const alertRed    = Color(0xFFD32F2F);
  static const alertOrange = Color(0xFFE65100);
  static const divider     = Color(0xFFDDD8CE);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.cardCream,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.cardCream,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.cardCream,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardCream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.sageGreen.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.sageGreen.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkGreen, width: 2),
      ),
    ),
  );
}