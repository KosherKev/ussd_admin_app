import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0B0F14);
  static const surfaceLow = Color(0xFF121417);
  static const primaryAmber = Color(0xFFFF8A3D);
  static const secondaryBlue = Color(0xFF3A7FA5);
  static const success = Color(0xFF36C577);
  static const warning = Color(0xFFE9B44C);
  static const error = Color(0xFFFF4D4F);
}

TextTheme _textTheme() {
  final base = GoogleFonts.interTextTheme();
  return base.copyWith(
    displayLarge: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
    titleLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    titleMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  );
}

ThemeData buildTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primaryAmber,
      secondary: AppColors.secondaryBlue,
      error: AppColors.error,
      surface: AppColors.surfaceLow,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme(),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryAmber, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.primaryAmber,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}