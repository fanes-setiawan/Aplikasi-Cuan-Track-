import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF10B981);

  static Color get primaryLight {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
  }

  static Color get primaryDark {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color divider = Color(0xFFEEEEEE);

  static Gradient get primaryGradient {
    return const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
