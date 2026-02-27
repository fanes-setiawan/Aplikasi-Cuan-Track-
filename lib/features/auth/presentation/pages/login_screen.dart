import 'package:cuan_track/features/main/presentation/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppDimens.md),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Texts
              Text(
                'Selamat Datang\nKembali',
                style: AppStyles.heading1.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                'Masuk untuk lanjut mengelola keuanganmu secara cerdas.',
                style: AppStyles.bodyTextSecondary.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppDimens.xl + 16),

              // Form Fields
              const CustomTextField(
                label: 'Email',
                hintText: 'nama@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimens.md),
              const CustomTextField(
                label: 'Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: AppDimens.sm),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to Forgot Password
                  },
                  child: Text(
                    'Lupa Password?',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Login Button
              CustomButton(
                text: 'Masuk',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: AppDimens.xl),

              // Divider "ATAU MASUK DENGAN"
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                    ),
                    child: Text(
                      'ATAU MASUK DENGAN',
                      style: AppStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: AppDimens.xl),

              // Google Login Button
              CustomButton(
                text: 'Masuk dengan Google',
                onPressed: () {
                  // TODO: Implement Google Sign in
                },
                isOutlined: true,
                backgroundColor: AppColors.divider,
                icon: SvgPicture.asset(
                  AppAssets.iconGoogle,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: AppStyles.bodyTextSecondary,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar',
                      style: AppStyles.bodyText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
