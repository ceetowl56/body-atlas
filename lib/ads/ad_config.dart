/// Ad settings. Keep [useTestAds] = true while developing and testing.
///
/// IMPORTANT: Never click your own live ads. It can get your AdMob account
/// banned. Switch [useTestAds] to false only for the final release build,
/// after you paste your real ad unit IDs below.
class AdConfig {
  static const bool useTestAds = true;

  // Google's official test ad units for Android.
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // TODO: replace with your real ad unit IDs from the AdMob console.
  static const String _prodBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitial =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewarded = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get bannerId => useTestAds ? _testBanner : _prodBanner;
  static String get interstitialId =>
      useTestAds ? _testInterstitial : _prodInterstitial;
  static String get rewardedId => useTestAds ? _testRewarded : _prodRewarded;

  /// Show an interstitial after every Nth lesson page change.
  static const int lessonsPerInterstitial = 3;

  /// Minimum time between two interstitial ads.
  static const Duration minInterstitialGap = Duration(seconds: 90);
}
