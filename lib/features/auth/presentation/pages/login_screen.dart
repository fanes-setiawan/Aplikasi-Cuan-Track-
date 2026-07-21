import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:cuan_track/features/main/presentation/pages/main_screen.dart';
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
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            AppHelpers.showSnackBar(context, 'Login berhasil!');
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
                  Text(
                    'Selamat Datang\nKembali',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  const Text(
                    'Masuk untuk lanjut mengelola keuanganmu secara cerdas.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFcbd5e1),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl + 16),

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
                  const SizedBox(height: AppDimens.sm),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF34d399),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Masuk',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10b981), Color(0xFF2dd4bf)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          textColor: const Color(0xFF020617),
                          onPressed: () {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;
                            if (email.isNotEmpty && password.isNotEmpty) {
                              context.read<AuthBloc>().add(
                                LoginEvent(email, password),
                              );
                            } else {
                              AppHelpers.showSnackBar(
                                context,
                                'Email dan password tidak boleh kosong',
                                isError: true,
                              );
                            }
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
                          'ATAU MASUK DENGAN',
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
                    text: 'Masuk dengan Google',
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
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Color(0xFFcbd5e1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
                        child: const Text(
                          'Daftar',
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
