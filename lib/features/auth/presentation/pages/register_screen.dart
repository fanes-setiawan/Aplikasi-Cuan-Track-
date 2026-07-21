import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../main/presentation/pages/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppDimens.md),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(AppSizes.padding8),
              decoration: BoxDecoration(
                color: const Color(0xFF0f172a),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1e293b)),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            AppHelpers.showSnackBar(context, 'Registrasi berhasil!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai Perjalanan\nFinansialmu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  const Text(
                    'Buat akun untuk mulai mengelola keuanganmu dengan lebih baik hari ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFcbd5e1),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  CustomTextField(
                    label: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    fillColor: const Color(0xFF0f172a),
                    textColor: Colors.white,
                    labelColor: Colors.white,
                    hintColor: const Color(0xFF64748b),
                    borderColor: const Color(0xFF1e293b),
                  ),
                  const SizedBox(height: AppDimens.md),
                  CustomTextField(
                    label: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    fillColor: const Color(0xFF0f172a),
                    textColor: Colors.white,
                    labelColor: Colors.white,
                    hintColor: const Color(0xFF64748b),
                    borderColor: const Color(0xFF1e293b),
                  ),
                  const SizedBox(height: AppDimens.md),
                  CustomTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    fillColor: const Color(0xFF0f172a),
                    textColor: Colors.white,
                    labelColor: Colors.white,
                    hintColor: const Color(0xFF64748b),
                    borderColor: const Color(0xFF1e293b),
                  ),
                  const SizedBox(height: AppDimens.md),
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.history_outlined,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    fillColor: const Color(0xFF0f172a),
                    textColor: Colors.white,
                    labelColor: Colors.white,
                    hintColor: const Color(0xFF64748b),
                    borderColor: const Color(0xFF1e293b),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Daftar',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10b981), Color(0xFF2dd4bf)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          textColor: const Color(0xFF020617),
                          onPressed: () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            final confirmPassword =
                                _confirmPasswordController.text;

                            if (email.isEmpty ||
                                password.isEmpty ||
                                confirmPassword.isEmpty) {
                              AppHelpers.showSnackBar(
                                context,
                                'Semua field harus diisi',
                                isError: true,
                              );
                              return;
                            }

                            if (password != confirmPassword) {
                              AppHelpers.showSnackBar(
                                context,
                                'Password tidak cocok',
                                isError: true,
                              );
                              return;
                            }

                            context.read<AuthBloc>().add(
                              RegisterEvent(email, password),
                            );
                          },
                        ),
                  const SizedBox(height: AppDimens.xl),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF1e293b))),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                        ),
                        child: Text(
                          'ATAU DAFTAR DENGAN',
                          style: TextStyle(
                            color: Color(0xFF64748b),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF1e293b))),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xl),

                  CustomButton(
                    text: 'Daftar dengan Google',
                    onPressed: () {
                      context.read<AuthBloc>().add(LoginWithGoogleEvent());
                    },
                    isOutlined: true,
                    backgroundColor: const Color(0xFF1e293b),
                    textColor: Colors.white,
                    icon: SvgPicture.asset(
                      AppAssets.iconGoogle,
                      width: AppSizes.padding20,
                      height: AppSizes.paddingV20,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Color(0xFF34d399),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
