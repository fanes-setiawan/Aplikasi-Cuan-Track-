import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  StreamSubscription<DocumentSnapshot>? _premiumSubscription;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier<bool>(false);

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();

    _auth.authStateChanges().listen((user) {
      _premiumSubscription?.cancel();
      if (user != null) {
        _premiumSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
              final data = snapshot.data();
              final premium = data?['isPremium'] == true;
              _isPremium = premium;
              isPremiumNotifier.value = premium;

              if (premium) {
                _interstitialAd?.dispose();
                _interstitialAd = null;
              } else {
                _loadInterstitialAd();
              }
            });
      } else {
        _isPremium = false;
        isPremiumNotifier.value = false;
        _interstitialAd?.dispose();
        _interstitialAd = null;
      }
    });
  }

  void _loadInterstitialAd() {
    if (_isPremium || _isInterstitialAdLoading || _interstitialAd != null)
      return;

    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    if (_isPremium) return;
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd();
    }
  }

  void dispose() {
    _premiumSubscription?.cancel();
    _interstitialAd?.dispose();
    isPremiumNotifier.dispose();
  }
}
