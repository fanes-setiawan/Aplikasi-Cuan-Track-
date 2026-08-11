import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _dailyReminder = true;
  bool _monthlyReport = true;
  bool _promoOffer = false;
  bool _financialTips = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('dailyReminder') ?? true;
      _monthlyReport = prefs.getBool('monthlyReport') ?? true;
      _promoOffer = prefs.getBool('promoOffer') ?? false;
      _financialTips = prefs.getBool('financialTips') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
        centerTitle: true,
        title: Text('Pengaturan Notifikasi', style: AppStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          children: [
            _buildNotificationItem(
              icon: Icons.notifications_active_outlined,
              title: 'Pengingat Harian',
              subtitle: 'Ingatkan untuk mencatat transaksi setiap hari',
              value: _dailyReminder,
              onChanged: (val) {
                setState(() => _dailyReminder = val);
                _saveSetting('dailyReminder', val);
              },
              iconColor: const Color(0xFFF59E0B),
              iconBgColor: const Color(0xFFFEF3C7),
            ),
            SizedBox(height: AppSizes.paddingV12),
            _buildNotificationItem(
              icon: Icons.assessment_outlined,
              title: 'Laporan Bulanan',
              subtitle: 'Dapatkan ringkasan keuangan setiap akhir bulan',
              value: _monthlyReport,
              onChanged: (val) {
                setState(() => _monthlyReport = val);
                _saveSetting('monthlyReport', val);
              },
              iconColor: const Color(0xFF3B82F6),
              iconBgColor: const Color(0xFFDBEAFE),
            ),
            SizedBox(height: AppSizes.paddingV12),
            _buildNotificationItem(
              icon: Icons.local_offer_outlined,
              title: 'Promo & Penawaran',
              subtitle: 'Update promo menarik dan fitur baru kami',
              value: _promoOffer,
              onChanged: (val) {
                setState(() => _promoOffer = val);
                _saveSetting('promoOffer', val);
              },
              iconColor: const Color(0xFFEC4899),
              iconBgColor: const Color(0xFFFCE7F3),
            ),
            SizedBox(height: AppSizes.paddingV12),
            _buildNotificationItem(
              icon: Icons.lightbulb_outline,
              title: 'Tips Keuangan',
              subtitle: 'Tips cerdas mengelola keuangan pribadi Anda',
              value: _financialTips,
              onChanged: (val) {
                setState(() => _financialTips = val);
                _saveSetting('financialTips', val);
              },
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFFD1FAE5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.padding16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: AppSizes.padding16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }
}
