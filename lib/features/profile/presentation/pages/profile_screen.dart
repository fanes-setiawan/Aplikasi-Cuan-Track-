import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
          : null,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final isPremium = data?['isPremium'] == true;

        return Scaffold(
          backgroundColor: const Color(0xFF020617),
          appBar: AppBar(
            backgroundColor: const Color(0xFF020617),
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Profil dan Pengaturan',
              style: AppStyles.heading2.copyWith(color: Colors.white),
            ),
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
                    SizedBox(height: AppSizes.paddingV32),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSizes.padding4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: const Color(0xFF1E293B),
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.all(AppSizes.padding8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
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
                          SizedBox(height: AppSizes.paddingV16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: AppStyles.heading1.copyWith(
                                  fontSize: AppSizes.font24,
                                  color: Colors.white,
                                ),
                              ),
                              if (isPremium) ...[
                                SizedBox(width: AppSizes.padding8),
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Color(0xFFFFB300),
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: AppSizes.paddingV4),
                          Text(
                            email,
                            style: AppStyles.bodyTextSecondary.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV24),
                    if (user != null)
                      _buildPremiumCard(context, isPremium, user.uid),
                    SizedBox(height: AppSizes.paddingV24),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                      ),
                      child: Column(
                        children: [
                          _buildProfileMenuItem(
                            icon: Icons.person_outline,
                            title: 'Informasi Akun',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountInfoScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppSizes.paddingV12),
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
                          SizedBox(height: AppSizes.paddingV12),
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
                          SizedBox(height: AppSizes.paddingV12),
                          _buildProfileMenuItem(
                            icon: Icons.file_upload_outlined,
                            title: 'Import Transaksi Excel',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ImportExcelScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppSizes.paddingV12),
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
                          SizedBox(height: AppSizes.paddingV12),
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
                          SizedBox(height: AppSizes.paddingV12),
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
                                      content: Text(
                                        'Tidak dapat membuka: $url',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingV32),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
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
                              const Icon(
                                Icons.logout,
                                color: Color(0xFFEF4444),
                              ),
                              SizedBox(width: AppSizes.padding12),
                              Text(
                                'Keluar',
                                style: AppStyles.bodyText.copyWith(
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingV24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                      ),
                      child: InkWell(
                        onTap: () => _showDeleteAccountDialog(context),
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF450a0a),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.delete_forever_outlined,
                                  color: Color(0xFFEF4444),
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: AppSizes.padding16),
                              Expanded(
                                child: Text(
                                  'Hapus Akun',
                                  style: AppStyles.bodyText.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingV24),
                    Text(
                      'VERSI ${packageInfo.version}',
                      style: AppStyles.caption.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: AppSizes.font10,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isPremium, String uid) {
    if (isPremium) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        padding: EdgeInsets.all(AppSizes.padding20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.padding12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFFFFB300),
                size: 28,
              ),
            ),
            SizedBox(width: AppSizes.padding16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Cuan Premium Aktif',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFFFFD700),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingV4),
                  Text(
                    'Kamu telah membuka seluruh fitur eksklusif bebas iklan & prioritas AI.',
                    style: AppStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: AppSizes.font12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      padding: EdgeInsets.all(AppSizes.padding20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.padding8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSizes.padding12),
              Text(
                'Cuan Track Premium',
                style: AppStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingV12),
          Text(
            'Kelola keuangan lebih cerdas dengan AI prioritas, tanpa iklan, dan analisis finansial tak terbatas!',
            style: AppStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: AppSizes.font12,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.paddingV16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _showUpgradeBottomSheet(context, uid),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF8F00),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Upgrade Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeBottomSheet(BuildContext context, String uid) {
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius24),
          topRight: Radius.circular(AppSizes.radius24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV20),
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFFFFB300),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bergabung ke Premium',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  _buildBenefitItem(
                    Icons.block,
                    'Bebas Iklan',
                    'Catat keuangan bersih tanpa jeda iklan.',
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  _buildBenefitItem(
                    Icons.bolt,
                    'CuanAI Prioritas',
                    'Analisis obrolan asisten AI 10x lebih responsif.',
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  _buildBenefitItem(
                    Icons.analytics_outlined,
                    'Analisis Finansial Plus',
                    'Laporan kesehatan keuangan tak terbatas.',
                  ),
                  SizedBox(height: AppSizes.paddingV24),

                  // Plan Option Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizes.padding16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      border: Border.all(
                        color: const Color(0xFFFFD54F),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radius16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akses Premium Bulanan',
                                style: AppStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingV4),
                              Text(
                                'Batalkan kapan saja.',
                                style: AppStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSizes.padding12),
                        Text(
                          'Rp 29.000 / bln',
                          style: AppStyles.heading2.copyWith(
                            color: const Color(0xFFFF8F00),
                            fontSize: AppSizes.font16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setSheetState(() => isLoading = true);

                              // Simulasi pembayaran 2 detik
                              await Future.delayed(const Duration(seconds: 2));

                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .set({
                                      'isPremium': true,
                                      'upgradedAt':
                                          FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));

                                if (context.mounted) {
                                  Navigator.pop(context); // Close bottom sheet
                                  // Show success snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Selamat! Akun Anda berhasil di-upgrade ke Premium. 🎉',
                                      ),
                                      backgroundColor: Color(0xFF4CAF50),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal melakukan upgrade: $e',
                                      ),
                                      backgroundColor: const Color(0xFFE53935),
                                    ),
                                  );
                                }
                              } finally {
                                setSheetState(() => isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: AppSizes.paddingV20,
                              width: AppSizes.padding20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Aktifkan Cuan Premium',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFF8F00), size: 20),
        SizedBox(width: AppSizes.padding12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.font12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.padding8),
              decoration: BoxDecoration(
                color: const Color(0xFF450a0a),
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            SizedBox(width: AppSizes.padding12),
            Text(
              'Hapus Akun',
              style: AppStyles.heading2.copyWith(
                color: const Color(0xFFEF4444),
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
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppSizes.paddingV12),
            Text(
              'Semua data berikut akan dihapus secara permanen:',
              style: AppStyles.bodyText.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
            SizedBox(height: AppSizes.paddingV8),
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
                    color: const Color(0xFF94A3B8),
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
                color: const Color(0xFF94A3B8),
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
              backgroundColor: const Color(0xFFEF4444),
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
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF10B981), size: 22),
            ),
            SizedBox(width: AppSizes.padding16),
            Expanded(
              child: Text(
                title,
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}
