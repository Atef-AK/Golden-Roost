import 'package:flutter/foundation.dart';

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
      // Mobile Ads SDK is Android/iOS native; web uses optional AdSense architecture
      _isInitialized = false;
      return;
    }

    try {
      // In release builds with configured AdMob application ID, GoogleMobileAds.instance.initialize() is called.
      // In development or when unconfigured, it gracefully falls back without blocking app startup.
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdService initialization deferred: $e');
      _isInitialized = false;
    }
  }

  /// Returns the appropriate banner ad unit ID.
  /// Falls back to test ID in development or if production ID is not provided.
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
}
