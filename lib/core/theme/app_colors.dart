import 'package:flutter/material.dart';
import 'package:cuan_track/injection_container.dart';
import 'package:cuan_track/core/services/remote_config_service.dart';

class AppColors {
  AppColors._();

  static Color _parseColor(String hexString) {
    String cleanHex = hexString.replaceAll('#', '').trim();
    if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
      cleanHex = cleanHex.substring(2);
    }
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse(cleanHex, radix: 16));
  }

  static Color get primary {
    try {
      final remoteConfig = sl<RemoteConfigService>();
      final String colorStr = remoteConfig.primaryColor.trim();
      if (colorStr.isNotEmpty) {
        return _parseColor(colorStr);
      }
    } catch (_) {}
    return const Color(0xFF4CAF50);
  }

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
    try {
      final List<String> colorsList = sl<RemoteConfigService>().primaryGradientColors;
      if (colorsList.isNotEmpty) {
        final parsedColors = colorsList.map((c) => _parseColor(c)).toList();
        if (parsedColors.length >= 2) {
          return LinearGradient(
            colors: parsedColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        }
      }
    } catch (_) {}
    return const LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
