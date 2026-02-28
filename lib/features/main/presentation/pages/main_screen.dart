import 'package:cuan_track/features/budget/presentation/pages/budget_screen.dart';
import 'package:cuan_track/features/history/presentation/pages/history_screen.dart';
import 'package:cuan_track/features/home/presentation/pages/home_screen.dart';
import 'package:cuan_track/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/local_auth_helper.dart';
import '../../../auth/presentation/pages/pin_lock_screen.dart';

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
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResume();
    }
  }

  Future<void> _handleAppResume() async {
    final prefs = await SharedPreferences.getInstance();
    final bool pinEnabled = prefs.getBool('pinEnabled') ?? false;
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;

    if (!pinEnabled && !_biometricEnabled) return;

    final String durationStr = prefs.getString('autoLockDuration') ?? 'Segera';
    if (durationStr == 'Tidak Pernah') return;

    if (_backgroundTime != null) {
      final elapsed = DateTime.now().difference(_backgroundTime!);
      final lockDuration = _parseDuration(durationStr);

      if (elapsed >= lockDuration) {
        setState(() => _isAppLocked = true);
        if (_biometricEnabled) {
          _authenticateBiometric();
        }
      }
    }
  }

  Duration _parseDuration(String durationStr) {
    switch (durationStr) {
      case 'Segera':
        return Duration.zero;
      case '1 Menit':
        return const Duration(minutes: 1);
      case '5 Menit':
        return const Duration(minutes: 5);
      case '15 Menit':
        return const Duration(minutes: 15);
      case '30 Menit':
        return const Duration(minutes: 30);
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
      if (_biometricEnabled) {
        _authenticateBiometric();
      }
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
    final String savedPin =
        prefs.getString('userPin') ?? '1234'; // Default PIN for now

    if (pin == savedPin) {
      setState(() => _isAppLocked = false);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN salah, silakan coba lagi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _updateIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: [
                  BottomNavigationBarItem(
                    icon: _buildIcon(AppAssets.iconHome, false),
                    activeIcon: _buildIcon(AppAssets.iconHome, true),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(AppAssets.iconHistory, false),
                    activeIcon: _buildIcon(AppAssets.iconHistory, true),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(AppAssets.iconBudget, false),
                    activeIcon: _buildIcon(AppAssets.iconBudget, true),
                    label: 'Budget',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(AppAssets.iconProfile, false),
                    activeIcon: _buildIcon(AppAssets.iconProfile, true),
                    label: 'Profile',
                  ),
                ],
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
