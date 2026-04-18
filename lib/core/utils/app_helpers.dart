import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  AppHelpers._();

  // --- UI Helpers ---

  /// Menampilkan snackbar kustom (Pill shaped, Icon + Text)
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(54),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/logo_app.png', height: 24, width: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menutup keyboard dengan mudah
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Mendapatkan lebar layar
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Mendapatkan tinggi layar
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // --- Formatters ---

  /// Format Rupiah (contoh: Rp 10.000)
  static String formatCurrencyIdr(double amount) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  /// Format Tanggal (contoh: 12 Okt 2023)
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format Waktu (contoh: 14:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // --- Validators ---

  /// Validasi input tidak boleh kosong
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi format email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi panjang minimal password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  // --- Utilities ---

  /// Delay eksekusi beberapa saat
  static Future<void> delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Mendapatkan IconData berdasarkan nama ikon kategori
  static IconData getCategoryIcon(String? name) {
    if (name == null) return Icons.category_outlined;
    final iconName = name.toLowerCase();
    if (iconName.contains('salary')) return Icons.payments_outlined;
    if (iconName.contains('business')) return Icons.business_center_outlined;
    if (iconName.contains('bonus')) return Icons.stars_outlined;
    if (iconName.contains('invest')) return Icons.show_chart_outlined;
    if (iconName.contains('food')) return Icons.fastfood_outlined;
    if (iconName.contains('transport')) return Icons.directions_car_outlined;
    if (iconName.contains('shopping')) return Icons.shopping_bag_outlined;
    if (iconName.contains('entertainment')) return Icons.sports_esports_outlined;
    if (iconName.contains('home')) return Icons.home_outlined;
    if (iconName.contains('heart')) return Icons.favorite_border_outlined;
    if (iconName.contains('cafe')) return Icons.local_cafe_outlined;
    if (iconName.contains('travel')) return Icons.flight_takeoff_outlined;
    if (iconName.contains('education')) return Icons.school_outlined;
    if (iconName.contains('savings')) return Icons.savings;
    if (iconName.contains('electronics')) return Icons.laptop_mac;
    if (iconName.contains('health')) return Icons.local_hospital;
    if (iconName.contains('camera')) return Icons.camera_alt;
    if (iconName.contains('phone')) return Icons.phone_iphone;
    return Icons.category_outlined;
  }
}
