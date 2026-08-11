import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/local_auth_helper.dart';
import '../../../../core/utils/app_helpers.dart';

class BiometricActivationScreen extends StatelessWidget {
  const BiometricActivationScreen({super.key});

  Future<void> _authenticate(BuildContext context) async {
    final bool available = await LocalAuthHelper.isBiometricAvailable();
    if (!available) {
      if (context.mounted) {
        AppHelpers.showSnackBar(
          context,
          'Biometrik tidak tersedia di perangkat ini',
          isError: true,
        );
      }
      return;
    }

    final bool success = await LocalAuthHelper.authenticate(
      reason: 'Scan sidik jari Anda untuk mengaktifkan fitur ini',
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricEnabled', true);

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        AppHelpers.showSnackBar(
          context,
          'Autentikasi gagal, silakan coba lagi',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(AppSizes.padding16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.padding8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF27AE60).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 250,
                    color: const Color(0xFFE2E8F0),
                  ),
                  Container(
                    width: 250,
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppSizes.padding24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Color(0xFF27AE60),
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    'Aktifkan Biometrik',
                    style: AppStyles.heading1.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  Text(
                    'Gunakan sidik jari atau pemindaian wajah Anda untuk akses yang lebih cepat dan aman.',
                    style: AppStyles.bodyTextSecondary.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: AppSizes.font16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _authenticate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radius16,
                          ),
                        ),
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF27AE60,
                        ).withValues(alpha: 0.3),
                      ),
                      child: Text(
                        'Mulai Pemindaian',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.font18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Nanti Saja',
                      style: AppStyles.bodyTextSecondary.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
                SizedBox(width: AppSizes.padding8),
                Text(
                  'DATA TERENKRIPSI & AMAN',
                  style: AppStyles.caption.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                    fontSize: AppSizes.font10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingV16),
          ],
        ),
      ),
    );
  }
}
