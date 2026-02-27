import 'package:cuan_track/core/theme/app_styles.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_event.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _handleNavigation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => hasSeenOnboarding
              ? const LoginScreen()
              : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            _handleNavigation(context);
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9)],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.logoApp,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppDimens.xl),

                      // App Title Asset
                      Image.asset(
                        AppAssets.logoText,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppDimens.sm),

                      // Subtitle
                      Text(
                        'SMART WEALTH MANAGER',
                        style: AppStyles.caption.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.xl + 8,
                      vertical: AppDimens.xl + 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SECURE SYNC',
                          style: AppStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: AppDimens.md - 4),
                        BlocBuilder<SplashBloc, SplashState>(
                          builder: (context, state) {
                            double progress = 0.0;
                            if (state is SplashLoading) {
                              progress = state.progress;
                            } else if (state is SplashLoaded) {
                              progress = 1.0;
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM + 2,
                              ),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.surface.withOpacity(
                                  0.5,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryDark,
                                ),
                                minHeight: 6,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimens.md),
                        Text(
                          'STABILITY & HEALTH • SINCE 2026',
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryDark.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
