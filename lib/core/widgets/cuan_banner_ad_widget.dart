import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../injection_container.dart';
import '../services/ad_service.dart';

class CuanBannerAdWidget extends StatefulWidget {
  final String? adUnitId;
  final bool showCloseButton;

  const CuanBannerAdWidget({
    super.key,
    this.adUnitId,
    this.showCloseButton = false,
  });

  @override
  State<CuanBannerAdWidget> createState() => _CuanBannerAdWidgetState();
}

class _CuanBannerAdWidgetState extends State<CuanBannerAdWidget> {
  final AdService _adService = sl<AdService>();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isClosed = false;

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
      adUnitId: widget.adUnitId ?? AdService.bannerAdUnitId,
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
        if (isPremium || !_isAdLoaded || _bannerAd == null || _isClosed) {
          return const SizedBox.shrink();
        }

        return Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: AppSizes.paddingV8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
              if (widget.showCloseButton)
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isClosed = true;
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
