import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.error,
    surface: AppColors.surface,
    background: AppColors.background,
  ),
  scaffoldBackgroundColor: AppColors.background,
  
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.grey900),
    displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.grey900),
    displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.grey900),
    headlineLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.grey900),
    headlineMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.grey900),
    headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey900),
    titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.grey900),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.grey900),
    titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey700),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.grey700),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.grey600),
    bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.grey500),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
  ),
  
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.grey900,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.grey900,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.grey50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.grey600,
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.grey400,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.grey100,
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.grey700,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);