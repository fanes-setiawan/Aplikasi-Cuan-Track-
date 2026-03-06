import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(
    0xFF4CAF50,
  ); // Cuan Track usually uses green
  static const Color primaryLight = Color(0xFF80E27E);
  static const Color primaryDark = Color(0xFF087f23);

  // Background and Surface Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Additional Colors
  static const Color divider = Color(0xFFEEEEEE);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
