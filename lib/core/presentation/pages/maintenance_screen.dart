import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../injection_container.dart';
import '../../services/remote_config_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../constants/app_dimens.dart';
import '../../utils/app_helpers.dart';

class MaintenanceScreen extends StatelessWidget {
  final bool isUpdateRequired;

  const MaintenanceScreen({super.key, this.isUpdateRequired = false});

  Future<void> _handleAction() async {
    final remoteConfig = sl<RemoteConfigService>();
    final url = remoteConfig.supportContactUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = sl<RemoteConfigService>();

    // Check if the custom 'background' parameter has been configured in Firebase Remote Config
    final hasBackgroundKey =
        remoteConfig.background.isNotEmpty &&
        remoteConfig.background != '0xFFFFFFFF';

    final startColor = AppHelpers.parseHexColor(
      remoteConfig.maintenanceBgStartColor,
      defaultColor: const Color(0xFFFFFFFF),
    );

    final endColor = AppHelpers.parseHexColor(
      hasBackgroundKey
          ? remoteConfig.background
          : remoteConfig.maintenanceBgEndColor,
      defaultColor: const Color(0xFFF3E5D8),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Premium Visual Illustration
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    isUpdateRequired
                        ? Icons.system_update_alt_rounded
                        : Icons.construction_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),
                // Heading
                Text(
                  isUpdateRequired ? 'Pembaruan Tersedia' : 'Peliharaan Sistem',
                  style: AppStyles.heading1.copyWith(
                    fontSize: 28,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.paddingV16),
                // Dynamic description
                Text(
                  isUpdateRequired
                      ? 'Versi aplikasi Anda sudah terlalu usang. Silakan unduh pembaruan terbaru untuk melanjutkan pengelolaan keuangan Anda secara lancar.'
                      : 'Kami sedang melakukan pemeliharaan sistem berkala untuk meningkatkan keamanan dan kecepatan sinkronisasi data Anda. Silakan coba beberapa saat lagi.',
                  style: AppStyles.bodyTextSecondary.copyWith(
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      ),
                    ),
                    child: Text(
                      isUpdateRequired
                          ? 'Perbarui Sekarang'
                          : 'Hubungi Bantuan / Dukungan',
                      style: AppStyles.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.paddingV32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
