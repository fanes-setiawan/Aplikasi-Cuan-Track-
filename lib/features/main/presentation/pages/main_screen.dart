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

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/local_auth_helper.dart';
import '../../../auth/presentation/pages/pin_lock_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/utils/app_helpers.dart';

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
        return const Duration(days: 365); // Large duration for "No Lock"
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

          // If app is locked, don't allow back button navigation
          if (_isAppLocked) return;

          // If not on the first tab (Dashboard), go back to it
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
            return;
          }

          // If on the first tab, handle double tap to exit
          final now = DateTime.now();
          final backButtonHasNotBeenPressedOrSnackBarHasExpired =
              _lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2);

          if (backButtonHasNotBeenPressedOrSnackBarHasExpired) {
            _lastPressedAt = now;
            AppHelpers.showSnackBar(context, 'Klik sekali lagi untuk keluar');
          } else {
            // Exit the app
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _pages),
              if (_isAppLocked)
                Positioned.fill(
                  child: PinLockScreen(
                    showBiometric: _biometricEnabled,
                    onPinCompleted: _handlePinCompleted,
                    onBiometricPressed: _authenticateBiometric,
                    onForgotPin: () {
                      // Handle forgot PIN
                    },
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _isAppLocked
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radiusXL),
                      topRight: Radius.circular(AppDimens.radiusXL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
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
                      backgroundColor: Colors.white,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: AppColors.textSecondary.withOpacity(
                        0.5,
                      ),
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pie_chart_outline,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          activeIcon: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pie_chart,
                              size: 24,
                              color: Colors.white,
                            ),
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
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isActive ? AppColors.primary : AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
