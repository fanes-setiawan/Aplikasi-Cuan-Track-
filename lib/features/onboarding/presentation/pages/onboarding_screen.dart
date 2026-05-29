import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingModel {
  final String imagePath;
  final String title;
  final String subtitle;

  OnboardingModel({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      imagePath: AppAssets.onboarding1,
      title: 'Pantau Setiap Rupiah',
      subtitle:
          'Catat dan pantau setiap pengeluaran harianmu dengan mudah untuk pengelolaan keuangan yang lebih baik.',
    ),
    OnboardingModel(
      imagePath: AppAssets.onboarding2,
      title: 'Atur Anggaran Cerdas',
      subtitle:
          'Kelola pengeluaran Anda dengan menetapkan batas anggaran yang realistis setiap bulannya agar target finansial tercapai.',
    ),
    OnboardingModel(
      imagePath: AppAssets.onboarding3,
      title: 'Capai Kebebasan Finansial',
      subtitle:
          'Wujudkan impianmu dengan perencanaan keuangan yang lebih matang, terukur, dan otomatis bersama kami.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage(int currentIndex) {
    if (currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: _buildAppBar(context, currentIndex),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().pageChanged(index);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPageContent(_pages[index]);
                      },
                    ),
                  ),
                  _buildFooter(context, currentIndex),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int index) {
    if (index == 0) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Skip',
              style: AppStyles.buttonText.copyWith(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
        ],
      );
    } else {
      String title = index == 1 ? 'Onboarding' : 'Financial Goals';
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        centerTitle: true,
        title: Text(title, style: AppStyles.heading2.copyWith(fontSize: 16)),
      );
    }
  }

  Widget _buildPageContent(OnboardingModel page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(page.imagePath, height: 300, fit: BoxFit.contain),
          const SizedBox(height: AppDimens.xl),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppStyles.heading1.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextSecondary.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (dotIndex) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: index == dotIndex ? 24 : 8,
                decoration: BoxDecoration(
                  color: index == dotIndex
                      ? AppColors.primary
                      : AppColors.primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.xl),

          _buildActionButtons(index),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int index) {
    if (index == 0) {
      return SizedBox(
        width: double.infinity,
        height: AppDimens.buttonHeightM,
        child: ElevatedButton(
          onPressed: () => _goToNextPage(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next', style: AppStyles.buttonText),
              const SizedBox(width: AppDimens.sm),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(
            width: index == 1 ? 200 : double.infinity,
            height: AppDimens.buttonHeightM,
            child: ElevatedButton(
              onPressed: () => _goToNextPage(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 1 ? 'Lanjutkan' : 'Mulai Sekarang',
                    style: AppStyles.buttonText,
                  ),
                  if (index == 1) ...[
                    const SizedBox(width: AppDimens.sm),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Lewati',
              style: AppStyles.bodyTextSecondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
  }
}
