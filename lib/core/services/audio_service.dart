import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _notifPlayer = AudioPlayer();
  final AudioPlayer _incomePlayer = AudioPlayer();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _successPlayer.setSource(AssetSource('sounds/success.mp3'));
      await _errorPlayer.setSource(AssetSource('sounds/error.mp3'));
      await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
      await _notifPlayer.setSource(AssetSource('sounds/notification.wav'));
      await _incomePlayer.setSource(AssetSource('sounds/income.mp3'));

      _successPlayer.setVolume(1.0);
      _errorPlayer.setVolume(1.0);
      _clickPlayer.setVolume(0.5);
      _notifPlayer.setVolume(0.5);
      _incomePlayer.setVolume(1.0);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  Future<void> playSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
      if (_successPlayer.state == PlayerState.playing) {
        await _successPlayer.stop();
      }
      await _successPlayer.resume();
    } catch (e) {
      debugPrint('Play success error: $e');
    }
  }

  Future<void> playError() async {
    try {
      await HapticFeedback.heavyImpact();
      if (_errorPlayer.state == PlayerState.playing) {
        await _errorPlayer.stop();
      }
      await _errorPlayer.resume();
    } catch (e) {
      debugPrint('Play error error: $e');
    }
  }

  Future<void> playClick() async {
    try {
      await HapticFeedback.lightImpact();
      if (_clickPlayer.state == PlayerState.playing) {
        await _clickPlayer.stop();
      }
      await _clickPlayer.resume();
    } catch (e) {
      debugPrint('Play click error: $e');
    }
  }

  Future<void> playNotification() async {
    try {
      await HapticFeedback.mediumImpact();
      if (_notifPlayer.state == PlayerState.playing) {
        await _notifPlayer.stop();
      }
      await _notifPlayer.resume();
    } catch (e) {
      debugPrint('Play notif error: $e');
    }
  }

  Future<void> playIncome() async {
    try {
      await HapticFeedback.mediumImpact();
      if (_incomePlayer.state == PlayerState.playing) {
        await _incomePlayer.stop();
      }
      await _incomePlayer.resume();
    } catch (e) {
      debugPrint('Play income error: $e');
    }
  }
}
