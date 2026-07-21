import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../injection_container.dart';
import '../services/ad_service.dart';

class CuanBannerAdWidget extends StatefulWidget {
  const CuanBannerAdWidget({super.key});

  @override
  State<CuanBannerAdWidget> createState() => _CuanBannerAdWidgetState();
}

class _CuanBannerAdWidgetState extends State<CuanBannerAdWidget> {
  final AdService _adService = sl<AdService>();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _adService.isPremiumNotifier.addListener(_onPremiumStatusChanged);
    _initAd();
  }

  void _onPremiumStatusChanged() {
    if (_adService.isPremium) {
      _disposeAd();
    } else {
      _initAd();
    }
  }

  void _initAd() {
    if (_adService.isPremium || _bannerAd != null) return;

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) {
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    _adService.isPremiumNotifier.removeListener(_onPremiumStatusChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _adService.isPremiumNotifier,
      builder: (context, isPremium, child) {
        if (isPremium || !_isAdLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          margin: EdgeInsets.symmetric(vertical: AppSizes.paddingV8),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
