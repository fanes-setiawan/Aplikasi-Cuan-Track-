import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi', style: AppStyles.heading2),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: Text(
              'Tandai Semua Dibaca',
              style: AppStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildSectionHeader('TERBARU'),
                _buildNotificationItem(
                  title: 'Peringatan Anggaran',
                  description: 'Peringatan: Anggaran Makan Siang terpakai 80%.',
                  time: 'Baru saja',
                  icon: Icons.notifications_active,
                  iconBgColor: const Color(0xFFFFECE0),
                  iconColor: const Color(0xFFFF8A00),
                  isUnread: true,
                ),
                _buildNotificationItem(
                  title: 'Laporan Mingguan',
                  description: 'Laporan Mingguan: Lihat ringkasan keuanganmu!',
                  time: '2j yang lalu',
                  icon: Icons.description,
                  iconBgColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF2196F3),
                  isUnread: true,
                ),
                const SizedBox(height: AppDimens.md),
                _buildSectionHeader('MINGGU INI'),
                _buildNotificationItem(
                  title: 'Pengingat Catatan',
                  description: 'Ingat: Catat pengeluaran kopimu tadi pagi.',
                  time: 'Senin, 09:00',
                  icon: Icons.edit_note,
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF4CAF50),
                ),
                _buildNotificationItem(
                  title: 'Transaksi Berhasil',
                  description:
                      'Transfer ke Tabungan Masa Depan telah berhasil diproses.',
                  time: 'Minggu, 18:30',
                  icon: Icons.account_balance_wallet,
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF4CAF50),
                ),
                _buildNotificationItem(
                  title: 'Tips Keuangan',
                  description:
                      'Kamu menghemat 15% lebih banyak bulan ini dibandingkan bulan lalu! Teruskan!',
                  time: 'Sabtu, 10:15',
                  icon: Icons.insights,
                  iconBgColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.5)),
      child: Text(
        title,
        style: AppStyles.caption.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isUnread
            ? const Color(0xFFE8F5E9).withOpacity(0.5)
            : Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(time, style: AppStyles.caption.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        description,
                        style: AppStyles.bodyTextSecondary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
