import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    error: AppColors.error,
    surface: AppColors.grey900,
    background: AppColors.grey900,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.grey900,
  primaryColor: AppColors.primaryLight,
  
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
  ),
  
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.grey900,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
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
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
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
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryLight,
      ),
    ),
  ),
  
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryLight,
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
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.grey400,
    ),
    hintStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.grey500,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: AppColors.grey800,
  ),
  
  listTileTheme: const ListTileThemeData(
    textColor: Colors.white,
    iconColor: AppColors.primaryLight,
  ),
);