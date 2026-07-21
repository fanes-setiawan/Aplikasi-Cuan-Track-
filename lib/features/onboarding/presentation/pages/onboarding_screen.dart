import 'package:cuan_track/features/onboarding/presentation/widgets/animations/scene_1_receipt_anim.dart';
import 'package:cuan_track/features/onboarding/presentation/widgets/animations/scene_2_budget_anim.dart';
import 'package:cuan_track/features/onboarding/presentation/widgets/animations/scene_3_rocket_anim.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cuan_track/core/utils/app_sizes.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingModel {
  final Widget animationWidget;
  final String title;
  final String subtitle;
  final String btnText;

  OnboardingModel({
    required this.animationWidget,
    required this.title,
    required this.subtitle,
    required this.btnText,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  late final List<OnboardingModel> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _pages = [
      OnboardingModel(
        animationWidget: const Scene1ReceiptAnim(),
        title: 'Pantau Setiap Rupiah',
        subtitle:
            'Catat dan pantau setiap pengeluaran harianmu dengan mudah untuk pengelolaan keuangan yang lebih baik.',
        btnText: 'Lanjut ke Atur Anggaran',
      ),
      OnboardingModel(
        animationWidget: const Scene2BudgetAnim(),
        title: 'Atur Anggaran Cerdas',
        subtitle:
            'Kelola pengeluaran Anda dengan menetapkan batas anggaran yang realistis setiap bulannya agar target finansial tercapai.',
        btnText: 'Lanjut ke Kebebasan Finansial',
      ),
      OnboardingModel(
        animationWidget: const Scene3RocketAnim(),
        title: 'Capai Kebebasan Finansial',
        subtitle:
            'Wujudkan impianmu dengan perencanaan keuangan yang lebih matang, terukur, dan otomatis bersama kami.',
        btnText: 'Mulai Sekarang',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage(int currentIndex) {
    if (currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
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
    // Set system UI to light text (since background is dark)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF020617),
      ),
    );

    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            // Dark Slate-950 background
            backgroundColor: const Color(0xFF020617),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(currentIndex),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().pageChanged(index);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        // We don't use the builder index directly to allow smooth swiping
                        // But we map the specific pages.
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

  Widget _buildHeader(int index) {
    if (index >= _pages.length - 1) {
      return const SizedBox(height: 56);
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding24,
        vertical: AppSizes.padding16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _finishOnboarding,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: Color(0xFFcbd5e1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingModel page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation Widget
          page.animationWidget,

          SizedBox(height: AppSizes.padding32),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.font24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.padding12),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFcbd5e1),
              fontSize: AppSizes.font14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.padding24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (dotIndex) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: AppSizes.padding4),
                height: 8,
                width: index == dotIndex ? 24 : 8,
                decoration: BoxDecoration(
                  color: index == dotIndex
                      ? const Color(0xFF34d399) // Emerald-400
                      : const Color(0xFF334155), // Slate-700
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.padding32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56, // Match HTML button height
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF10b981),
                    Color(0xFF2dd4bf),
                  ], // Emerald-500 to Teal-400
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10b981).withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _goToNextPage(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _pages[index].btnText,
                      style: TextStyle(
                        color: const Color(0xFF020617), // Slate-950
                        fontSize: AppSizes.font16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: AppSizes.padding8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF020617),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.padding16),
        ],
      ),
    );
  }
}
