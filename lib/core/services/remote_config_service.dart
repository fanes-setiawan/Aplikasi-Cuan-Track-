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
}
