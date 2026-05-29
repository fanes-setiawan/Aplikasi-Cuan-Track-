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
        'support_contact_url': 'https://wa.me/62088225409824',
        'min_app_version': '1.0.0',
        'maintenance_mode': false,
        'background': '0xFFFFFFFF',
        'maintenance_bg_start_color': '0xFFFFFFFF',
        'maintenance_bg_end_color': '0xFFF3E5D8',
      });

      // Configure Remote Config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration
                    .zero // Instant fetch in debug mode for rapid testing
              : const Duration(
                  hours: 1,
                ), // Fetch cached values every 1 hour in production
        ),
      );

      // Fetch from server and activate values instantly
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
}
