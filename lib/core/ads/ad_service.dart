import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  // Official Google AdMob sample test unit IDs
  static const String androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Mobile Ads SDK safely. Never crashes if offline or unsupported.
  Future<void> initialize() async {
    if (kIsWeb) {
      _isInitialized = false;
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdService initialization deferred or unavailable: $e');
      _isInitialized = false;
    }
  }

  /// Returns the appropriate banner ad unit ID.
  /// Falls back to official Google test ID in development or if production ID is not provided.
  String getBannerAdUnitId({String? productionAdUnitId}) {
    if (kReleaseMode &&
        productionAdUnitId != null &&
        productionAdUnitId.isNotEmpty) {
      return productionAdUnitId;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosBannerTestId
        : androidBannerTestId;
  }

  /// Safely creates a real native BannerAd with lifecycle listeners
  BannerAd? createBannerAd({
    required void Function() onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
    String? productionAdUnitId,
  }) {
    if (!_isInitialized || kIsWeb) return null;

    final adUnitId = getBannerAdUnitId(productionAdUnitId: productionAdUnitId);
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }
}
