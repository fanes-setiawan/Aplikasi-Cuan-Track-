import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'payment_methods_screen.dart';
import 'custom_categories_screen.dart';
import 'security_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profil dan Pengaturan', style: AppStyles.heading2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFFF3E5D8),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF27AE60),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User Name',
                    style: AppStyles.heading1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user.email@example.com',
                    style: AppStyles.bodyTextSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Settings Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: Column(
                children: [
                  _buildProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Informasi Akun',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Metode Pembayaran',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    icon: Icons.category_outlined,
                    title: 'Kategori Kustom',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    icon: Icons.fingerprint,
                    title: 'Keamanan (Fingerprint/PIN)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF5F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Color(0xFFFF5252)),
                      const SizedBox(width: 12),
                      Text(
                        'Keluar',
                        style: AppStyles.bodyText.copyWith(
                          color: const Color(0xFFFF5252),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'VERSI 1.0.42',
              style: AppStyles.caption.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF27AE60), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
