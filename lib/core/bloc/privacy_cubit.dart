import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyCubit extends Cubit<bool> {
  static const String _privacyKey = 'is_privacy_enabled';
  
  PrivacyCubit() : super(false) {
    _loadPrivacyState();
  }

  Future<void> _loadPrivacyState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_privacyKey) ?? false;
      emit(isEnabled);
    } catch (_) {
      // If SharedPreferences fails, default to false (already set by super)
    }
  }

  Future<void> togglePrivacy() async {
    final newState = !state;
    emit(newState);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_privacyKey, newState);
    } catch (_) {}
  }
}
