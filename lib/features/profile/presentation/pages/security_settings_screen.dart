import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'biometric_activation_screen.dart';
import 'package:cuan_track/features/auth/presentation/pages/change_pin_screen.dart';
import '../../../../core/utils/app_helpers.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  String _autoLockDuration = 'Segera';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getBool('pinEnabled') ?? false;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      _autoLockDuration = prefs.getString('autoLockDuration') ?? 'Segera';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
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
        title: Text('Keamanan', style: AppStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          children: [
            _buildSecurityToggleItem(
              icon: Icons.lock_outline,
              title: 'Kunci PIN',
              subtitle: 'Minta PIN saat aplikasi dibuka',
              value: _pinEnabled,
              onChanged: (val) async {
                if (val) {
                  final prefs = await SharedPreferences.getInstance();
                  final hasPin = prefs.getString('userPin') != null;
                  if (!hasPin) {
                    if (mounted) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePinScreen(),
                        ),
                      );
                      if (result == true) {
                        setState(() => _pinEnabled = true);
                      }
                    }
                    return;
                  }
                }
                setState(() => _pinEnabled = val);
                _saveSetting('pinEnabled', val);
              },
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFF0FDF4),
            ),
            const SizedBox(height: 12),
            _buildSecurityActionItem(
              icon: Icons.pin_outlined,
              title: 'Ubah PIN',
              subtitle: 'Ganti kode akses keamanan Anda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePinScreen(),
                  ),
                );
              },
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFF0FDF4),
            ),
            const SizedBox(height: 12),
            _buildSecurityToggleItem(
              icon: Icons.fingerprint,
              title: 'Sidik Jari / Face ID',
              subtitle: 'Login lebih cepat dan aman',
              value: _biometricEnabled,
              onChanged: (val) async {
                if (val) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BiometricActivationScreen(),
                    ),
                  );
                  if (result == true) {
                    setState(() => _biometricEnabled = true);
                    AppHelpers.showSnackBar(
                      context,
                      'Autentikasi biometrik diaktifkan',
                    );
                  }
                } else {
                  setState(() => _biometricEnabled = false);
                  _saveSetting('biometricEnabled', false);
                }
              },
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFF0FDF4),
            ),
            const SizedBox(height: 12),
            _buildSecurityDropdownItem(
              icon: Icons.timer_outlined,
              title: 'Otomatis Kunci',
              subtitle: 'Durasi sebelum terkunci otomatis',
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFF0FDF4),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF27AE60),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kami menggunakan enkripsi tingkat bank untuk memastikan data keuangan Anda tetap aman dan pribadi.',
                      style: AppStyles.bodyTextSecondary.copyWith(
                        color: const Color(0xFF1B5E20),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
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
                Text(subtitle, style: AppStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
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
                  Text(subtitle, style: AppStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityDropdownItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final List<String> durations = [
      'Segera',
      '15 Detik',
      '1 Menit',
      '5 Menit',
      'Tidak Ada',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
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
                Text(subtitle, style: AppStyles.caption),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() => _autoLockDuration = value);
              _saveSetting('autoLockDuration', value);
            },
            itemBuilder: (BuildContext context) {
              return durations.map((String duration) {
                return PopupMenuItem<String>(
                  value: duration,
                  child: Text(duration, style: AppStyles.bodyTextSecondary),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _autoLockDuration,
                    style: AppStyles.bodyTextSecondary.copyWith(
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF27AE60),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
