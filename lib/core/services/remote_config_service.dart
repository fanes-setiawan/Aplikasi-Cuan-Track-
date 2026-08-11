import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      // Set baseline in-app default values
      await _remoteConfig.setDefaults(<String, dynamic>{
        'enable_ai_chat': true,
        'support_contact_url': '',
        'min_app_version': '1.0.0',
        'maintenance_mode': false,
        'background': '0xFFFFFFFF',
        'maintenance_bg_start_color': '0xFFFFFFFF',
        'maintenance_bg_end_color': '0xFFF3E5D8',
        'onboarding1': '',
        'onboarding2': '',
        'onboarding3': '',
        'primary': '0xFF4CAF50',
        'primaryGradient': '["0xFF1B5E20", "0xFF2E7D32"]',
        'fh_target_saving_ratio': '0.20',
        'fh_target_debt_ratio': '0.35',
        'fh_target_emergency_months': '3.0',
        'fh_ai_model': 'gemini-2.5-flash',
        'fh_ai_prompt_template':
            'Rangkum kondisi keuangan pengguna berikut dalam 2-3 kalimat ramah dan solutif (panggil \'kamu\', berikan 1 saran spesifik untuk meningkatkan skor kesehatan keuangan mereka):\n- Pendapatan Bulanan: Rp {income}\n- Pengeluaran Bulanan: Rp {expense}\n- Total Tabungan saat ini: Rp {savings}\n- Total Hutang saat ini: Rp {debt}\n- Saving Ratio: {savingRatio}% (Target: >{targetSaving}%)\n- Debt-to-Income Ratio: {debtRatio}% (Target: <{targetDebt}%)\n- Dana Darurat: {emergencyFundRatio} bulan pengeluaran (Target: {targetEmergency} bulan)\n\nJawab langsung dengan saran praktis tanpa kalimat pengantar basa-basi formal. Gunakan bahasa Indonesia.',
        'fh_share_toast_message': 'Fitur berbagi segera hadir!',
        'fh_enable_simulation': true,
        'chat_ai_model': 'gemini-2.5-flash',
        'chat_ai_system_instruction':
            'Kamu adalah CuanAI, asisten keuangan pribadi yang sangat cerdas, analitis, sekaligus ramah.\nTugas utamamu adalah membantu pengguna mengelola keuangan dengan bijak, memberikan wawasan mendalam (insights), dan menjawab pertanyaan seputar transaksi mereka dengan detail serta empati.\n\nDATA KEUANGAN PENGGUNA (Gunakan ini sebagai sumber kebenaran):\n{context}\n\nKEPRIBADIAN & GAYA BICARA:\n- Gunakan bahasa yang cerdas, ramah, dan solutif (panggil \'kamu\', gunakan \'aku\', \'sip\', \'mantap\').\n- Jadilah asisten yang proaktif namun tetap ringkas. Berikan analisis atau tips hanya jika sangat relevan agar tidak bertele-tele.\n- Gunakan emoji yang relevan namun proporsional (jangan terlalu banyak).\n- JANGAN PERNAH memakai kalimat kaku seperti "Berdasarkan data yang Anda berikan" atau "Saya tidak punya akses ke mutasi". Berbicaralah seolah-olah kamu adalah partner finansial yang memantau catatan keuangan mereka secara langsung.\n\nATURAN JAWABAN:\n1. Analisis transaksi atau wawasan harus didukung oleh DATA KEUANGAN PENGGUNA.\n2. Jika pengguna menanyakan ringkasan pengeluaran atau pemasukan, hitung dan berikan ringkasan yang jelas.\n3. Berikan saran hemat atau investasi yang realistis berdasarkan kemampuan tabungan mereka.',
      });

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Firebase Remote Config Initialization Failed: $e');
    }
  }

  // Getter methods to fetch config values synchronously across screens
  bool get enableAIChat => _remoteConfig.getBool('enable_ai_chat');

  String get supportContactUrl =>
      _remoteConfig.getString('support_contact_url');

  String get minAppVersion => _remoteConfig.getString('min_app_version');

  bool get maintenanceMode => _remoteConfig.getBool('maintenance_mode');

  String get maintenanceBgStartColor =>
      _remoteConfig.getString('maintenance_bg_start_color');

  String get maintenanceBgEndColor =>
      _remoteConfig.getString('maintenance_bg_end_color');

  String get background => _remoteConfig.getString('background');

  String get onboarding1Url => _remoteConfig.getString('onboarding1');
  String get onboarding2Url => _remoteConfig.getString('onboarding2');
  String get onboarding3Url => _remoteConfig.getString('onboarding3');

  String get primaryColor => _remoteConfig.getString('primary');

  List<String> get primaryGradientColors {
    try {
      final String jsonStr = _remoteConfig.getString('primaryGradient');
      if (jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  // Getters for Financial Health
  double get fhTargetSavingRatio {
    try {
      return double.tryParse(
            _remoteConfig.getString('fh_target_saving_ratio'),
          ) ??
          0.20;
    } catch (_) {
      return 0.20;
    }
  }

  double get fhTargetDebtRatio {
    try {
      return double.tryParse(_remoteConfig.getString('fh_target_debt_ratio')) ??
          0.35;
    } catch (_) {
      return 0.35;
    }
  }

  double get fhTargetEmergencyMonths {
    try {
      return double.tryParse(
            _remoteConfig.getString('fh_target_emergency_months'),
          ) ??
          3.0;
    } catch (_) {
      return 3.0;
    }
  }

  String get fhAiModel => _remoteConfig.getString('fh_ai_model');

  String get fhAiPromptTemplate =>
      _remoteConfig.getString('fh_ai_prompt_template');

  String get fhShareToastMessage =>
      _remoteConfig.getString('fh_share_toast_message');

  bool get fhEnableSimulation => _remoteConfig.getBool('fh_enable_simulation');

  // Getters for AI Chat
  String get chatAiModel => _remoteConfig.getString('chat_ai_model');

  String get chatAiSystemInstruction =>
      _remoteConfig.getString('chat_ai_system_instruction');
}
