import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    error: AppColors.errorLight,
    surface: AppColors.grey900,
    background: AppColors.grey900,
  ),
  scaffoldBackgroundColor: AppColors.grey900,
  
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
    bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey),
    bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
    bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
  ),
  
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
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
      foregroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.primaryLight),
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
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.grey800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.grey700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.grey700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorLight),
    ),
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.grey400,
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.grey500,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: AppColors.grey800,
  ),
);