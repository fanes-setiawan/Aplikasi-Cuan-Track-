import 'package:cuan_track/features/budget/presentation/pages/budget_screen.dart';
import 'package:cuan_track/features/history/presentation/pages/history_screen.dart';
import 'package:cuan_track/features/home/presentation/pages/home_screen.dart';
import 'package:cuan_track/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
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
