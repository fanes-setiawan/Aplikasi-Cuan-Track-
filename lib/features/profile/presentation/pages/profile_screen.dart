import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'payment_methods_screen.dart';
import 'custom_categories_screen.dart';
import 'account_info_screen.dart';
import 'security_settings_screen.dart';
import 'notification_settings_screen.dart';
import '../../../home/presentation/pages/import_excel_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/remote_config_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packageInfo = sl<PackageInfo>();
    final remoteConfig = sl<RemoteConfigService>();
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Belum login';
    final name =
        user?.displayName ??
        (email.contains('@') ? email.split('@')[0] : 'User Name');
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profil dan Pengaturan', style: AppStyles.heading2),
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                const SizedBox(height: 32),
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
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.8),
                                    )
                                  : null,
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
                        name,
                        style: AppStyles.heading1.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: AppStyles.bodyTextSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                  child: Column(
                    children: [
                      _buildProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Informasi Akun',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountInfoScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProfileMenuItem(
                        icon: Icons.payments_outlined,
                        title: 'Metode Pembayaran',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentMethodsScreen(),
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
                              builder: (context) =>
                                  const CustomCategoriesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProfileMenuItem(
                        icon: Icons.file_upload_outlined,
                        title: 'Import Transaksi Excel',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImportExcelScreen(),
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
                              builder: (context) =>
                                  const SecuritySettingsScreen(),
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
                        onTap: () async {
                          final url = remoteConfig.supportContactUrl;
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tidak dapat membuka: $url'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
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
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusM,
                          ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                  child: InkWell(
                    onTap: () => _showDeleteAccountDialog(context),
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    child: Container(
                      width: double.infinity,
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
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_forever_outlined,
                              color: Color(0xFFE53935),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Hapus Akun',
                              style: AppStyles.bodyText.copyWith(
                                color: const Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFE53935),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'VERSI ${packageInfo.version}',
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
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Akun',
              style: AppStyles.heading2.copyWith(
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tindakan ini tidak dapat dibatalkan!',
              style: AppStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Semua data berikut akan dihapus secara permanen:',
              style: AppStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...[
              '• Semua transaksi',
              '• Anggaran (budget)',
              '• Kategori kustom',
              '• Metode pembayaran',
              '• Tabungan & hutang',
              '• Akun Firebase Auth',
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(DeleteAccountEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
            ),
            child: Text(
              'Ya, Hapus Akun',
              style: AppStyles.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                color: AppColors.primary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
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
