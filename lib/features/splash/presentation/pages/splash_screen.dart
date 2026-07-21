import 'package:cuan_track/features/main/presentation/pages/main_screen.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:cuan_track/core/presentation/pages/maintenance_screen.dart';
import 'package:cuan_track/core/services/remote_config_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cuan_track/injection_container.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_event.dart';
import 'package:cuan_track/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigationTriggered = false;

  bool _isVersionBelow(String current, String minimum) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final minParts = minimum.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        final minVal = i < minParts.length ? minParts[i] : 0;

        if (currentVal < minVal) return true;
        if (currentVal > minVal) return false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _handleNavigation(
    BuildContext context,
    AuthState authState,
  ) async {
    final remoteConfig = sl<RemoteConfigService>();

    if (remoteConfig.maintenanceMode) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MaintenanceScreen(isUpdateRequired: false),
          ),
        );
      }
      return;
    }

    final packageInfo = sl<PackageInfo>();
    final currentVersion = packageInfo.version;
    final minVersion = remoteConfig.minAppVersion;

    if (_isVersionBelow(currentVersion, minVersion)) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MaintenanceScreen(isUpdateRequired: true),
          ),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!context.mounted) return;

    Widget nextScreen;
    if (authState is Authenticated) {
      nextScreen = const MainScreen();
    } else if (authState is Unauthenticated || authState is AuthError) {
      nextScreen = hasSeenOnboarding
          ? const LoginScreen()
          : const OnboardingScreen();
    } else {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  void _checkAndNavigate(BuildContext context) {
    if (_navigationTriggered) return;

    final splashState = context.read<SplashBloc>().state;
    final authState = context.read<AuthBloc>().state;

    if (splashState is SplashLoaded) {
      if (authState is Authenticated ||
          authState is Unauthenticated ||
          authState is AuthError) {
        _navigationTriggered = true;
        _handleNavigation(context, authState);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashStarted()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SplashBloc, SplashState>(
            listener: (context, state) {
              _checkAndNavigate(context);
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              _checkAndNavigate(context);
            },
          ),
        ],
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFd1fae5),
                  Color(0xFFecfdf5),
                  Color(0xFFccfbf1),
                ],
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
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF6ee7b7).withOpacity(0.4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6ee7b7,
                                  ).withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10b981),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF34d399),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10b981,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 4,
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 10,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 10,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Positioned(
                            top: -10,
                            right: -10,
                            child: Text('✨', style: TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimens.xxl),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Cuan',
                              style: TextStyle(
                                color: Color(0xFF0f172a),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Track',
                              style: TextStyle(
                                color: Color(0xFF10b981),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SMART WEALTH MANAGER',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFa7f3d0).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF34d399).withOpacity(0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.shield_outlined,
                                color: Color(0xFF059669),
                                size: 12,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'SECURE SYNC',
                                style: TextStyle(
                                  color: Color(0xFF022c22),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.cloud_sync_outlined,
                                color: Color(0xFF059669),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.md),

                        BlocBuilder<SplashBloc, SplashState>(
                          builder: (context, state) {
                            double progress = 0.0;
                            if (state is SplashLoading) {
                              progress = state.progress;
                            } else if (state is SplashLoaded) {
                              progress = 1.0;
                            }
                            return Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFa7f3d0).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6ee7b7,
                                  ).withOpacity(0.8),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF10b981),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimens.md),

                        const Text(
                          'STABILITY & HEALTH • SINCE 2026',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065f46),
                            letterSpacing: 1.0,
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
