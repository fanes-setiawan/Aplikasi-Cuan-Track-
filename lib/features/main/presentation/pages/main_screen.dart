import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:cuan_track/features/budget/presentation/pages/budget_screen.dart';
import 'package:cuan_track/features/history/presentation/pages/history_screen.dart';
import 'package:cuan_track/features/home/presentation/pages/home_screen.dart';
import 'package:cuan_track/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:cuan_track/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/audio_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/local_auth_helper.dart';
import '../../../auth/presentation/pages/pin_lock_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../ai_chat/presentation/pages/ai_chat_screen.dart';
import '../../../ai_chat/presentation/bloc/ai_chat_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/remote_config_service.dart';
import 'package:cuan_track/features/onboarding/presentation/widgets/animations/animated_pulse_glow_widget.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<_MainScreenState> mainScreenKey =
      GlobalKey<_MainScreenState>();
  const MainScreen({super.key});

  static void switchTab(int index) {
    mainScreenKey.currentState?._updateIndex(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isAppLocked = false;
  bool _biometricEnabled = false;
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAppLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('DEBUG: AppLifecycleState changed to: $state');
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      print('DEBUG: App paused at: $_backgroundTime');
    } else if (state == AppLifecycleState.resumed) {
      print('DEBUG: App resumed. Calling _handleAppResume...');
      _handleAppResume();
    }
  }

  Future<void> _handleAppResume() async {
    final prefs = await SharedPreferences.getInstance();
    final bool pinEnabled = prefs.getBool('pinEnabled') ?? false;
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;

    if (!pinEnabled && !_biometricEnabled) return;

    final String durationStr = prefs.getString('autoLockDuration') ?? 'Segera';
    if (durationStr == 'Tidak Ada') return;

    if (_backgroundTime != null) {
      final elapsed = DateTime.now().difference(_backgroundTime!);
      final lockDuration = _parseDuration(durationStr);
      print('DEBUG: Elapsed time since background: ${elapsed.inSeconds}s');
      print('DEBUG: Lock duration required: ${lockDuration.inSeconds}s');

      if (elapsed >= lockDuration) {
        print('DEBUG: Locking app...');
        setState(() => _isAppLocked = true);
      } else {
        print('DEBUG: Not enough time elapsed to lock.');
      }
    } else {
      print('DEBUG: _backgroundTime is null, skipping lock check.');
    }
  }

  Duration _parseDuration(String durationStr) {
    switch (durationStr) {
      case 'Segera':
        return Duration.zero;
      case '15 Detik':
        return const Duration(seconds: 15);
      case '1 Menit':
        return const Duration(minutes: 1);
      case '5 Menit':
        return const Duration(minutes: 5);
      case 'Tidak Ada':
        return const Duration(days: 365);
      default:
        return Duration.zero;
    }
  }

  Future<void> _checkAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    final bool pinEnabled = prefs.getBool('pinEnabled') ?? false;
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;

    if (pinEnabled || _biometricEnabled) {
      setState(() => _isAppLocked = true);
    }
  }

  Future<void> _authenticateBiometric() async {
    final bool success = await LocalAuthHelper.authenticate(
      reason: 'Harap verifikasi identitas Anda untuk masuk',
    );

    if (success) {
      setState(() => _isAppLocked = false);
    }
  }

  Future<void> _handlePinCompleted(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final String savedPin = prefs.getString('userPin') ?? '1234';

    if (pin == savedPin) {
      setState(() => _isAppLocked = false);
    } else {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'PIN salah, silakan coba lagi',
          isError: true,
        );
      }
    }
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const AnalyticsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _updateIndex(int index) {
    if (_currentIndex != index) {
      AudioService().playClick();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          if (_isAppLocked) return;

          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
            return;
          }

          final now = DateTime.now();
          final backButtonHasNotBeenPressedOrSnackBarHasExpired =
              _lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2);

          if (backButtonHasNotBeenPressedOrSnackBarHasExpired) {
            _lastPressedAt = now;
            AppHelpers.showSnackBar(context, 'Klik sekali lagi untuk keluar');
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF020617),
          body: Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _pages),
              if (_isAppLocked)
                Positioned.fill(
                  child: PinLockScreen(
                    showBiometric: _biometricEnabled,
                    onPinCompleted: _handlePinCompleted,
                    onBiometricPressed: _authenticateBiometric,
                    onForgotPin: () {},
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _isAppLocked
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radiusXL),
                      topRight: Radius.circular(AppDimens.radiusXL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF1E293B),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radiusXL),
                      topRight: Radius.circular(AppDimens.radiusXL),
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: _updateIndex,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: const Color(0xFF0F172A),
                      selectedItemColor: const Color(0xFF10B981),
                      unselectedItemColor: const Color(0xFF64748B),
                      selectedFontSize: 12,
                      unselectedFontSize: 10,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 0,
                      items: [
                        BottomNavigationBarItem(
                          icon: _buildIcon(AppAssets.iconHome, false),
                          activeIcon: _buildIcon(AppAssets.iconHome, true),
                          label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildIcon(AppAssets.iconHistory, false),
                          activeIcon: _buildIcon(AppAssets.iconHistory, true),
                          label: 'Riwayat',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                            padding: EdgeInsets.all(AppSizes.padding12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: _buildIcon(AppAssets.iconStats, false),
                          ),
                          activeIcon: Container(
                            padding: EdgeInsets.all(AppSizes.padding12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: _buildIcon(AppAssets.iconStats, true),
                          ),
                          label: 'Stats',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildIcon(AppAssets.iconBudget, false),
                          activeIcon: _buildIcon(AppAssets.iconBudget, true),
                          label: 'Anggaran',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildIcon(AppAssets.iconProfile, false),
                          activeIcon: _buildIcon(AppAssets.iconProfile, true),
                          label: 'Profil',
                        ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton:
              _isAppLocked || !sl<RemoteConfigService>().enableAIChat
              ? null
              : AnimatedPulseGlowWidget(
                  child: FloatingActionButton(
                    onPressed: () {
                      AudioService().playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => sl<AIChatBloc>(),
                            child: const AIChatScreen(),
                          ),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: Container(
                      padding: EdgeInsets.all(AppSizes.padding12),
                      child: SvgPicture.asset(
                        AppAssets.iconBot,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF020617),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SvgPicture.asset(
        assetPath,
        width: AppSizes.padding24,
        height: AppSizes.paddingV24,
        colorFilter: ColorFilter.mode(
          isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
