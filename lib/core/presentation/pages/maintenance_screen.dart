import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../injection_container.dart';
import '../../services/remote_config_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../constants/app_dimens.dart';
import 'dart:io' show Platform;

class MaintenanceScreen extends StatelessWidget {
  final bool isUpdateRequired;
  final String? storeUrl;

  const MaintenanceScreen({
    super.key,
    this.isUpdateRequired = false,
    this.storeUrl,
  });

  Future<void> _handleAction() async {
    final remoteConfig = sl<RemoteConfigService>();

    final defaultStoreUrl = Platform.isIOS
        ? 'https://apps.apple.com/app/idYOUR_APP_ID'
        : 'https://play.google.com/store/apps/details?id=com.fanes.cuan_track';

    // If update is required, prioritize the Store URL. Otherwise, use support contact URL.
    final targetUrl = isUpdateRequired
        ? (storeUrl ?? defaultStoreUrl)
        : remoteConfig.supportContactUrl;

    if (targetUrl.isNotEmpty) {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -100,
            left: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 4.seconds,
                    ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child:
                Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(0.9, 0.9),
                      duration: 3.seconds,
                    ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Premium Visual Illustration
                  Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow Effect
                          Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: 2.seconds,
                              ),

                          // Inner subtle ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                            ),
                          ),

                          // Icon Container
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  blurRadius: 10,
                                  offset: const Offset(-5, -5),
                                ),
                              ],
                            ),
                            child: Icon(
                              isUpdateRequired
                                  ? Icons.rocket_launch_rounded
                                  : Icons.construction_rounded,
                              size: 56,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fade(duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 56),

                  // Heading
                  Text(
                        isUpdateRequired
                            ? 'Pembaruan Penting!'
                            : 'Sedang Dipelihara',
                        style: AppStyles.heading1.copyWith(
                          fontSize: 32,
                          color: const Color(0xFF1E293B), // Slate 800
                          height: 1.2,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fade(delay: 200.ms, duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                  SizedBox(height: AppSizes.paddingV16),

                  // Dynamic description
                  Text(
                        isUpdateRequired
                            ? 'Versi terbaru aplikasi Cuan Track sudah tersedia! Yuk perbarui sekarang untuk menikmati fitur baru dan pengalaman yang lebih mulus.'
                            : 'Kami sedang melakukan pemeliharaan sistem berkala untuk meningkatkan keamanan dan kecepatan. Silakan coba beberapa saat lagi.',
                        style: AppStyles.bodyTextSecondary.copyWith(
                          fontSize: 15,
                          height: 1.6,
                          color: const Color(0xFF64748B), // Slate 500
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fade(delay: 400.ms, duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),

                  const Spacer(),

                  // Action Button
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isUpdateRequired
                                ? 'Perbarui Sekarang'
                                : 'Hubungi Bantuan',
                            style: AppStyles.bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fade(delay: 600.ms, duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad)
                      .shimmer(
                        delay: 2.seconds,
                        duration: 1.5.seconds,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),

                  SizedBox(height: AppSizes.paddingV32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
