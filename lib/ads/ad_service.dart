import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Handles ad consent (Google UMP), SDK start-up, interstitial and rewarded ads.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Set to false in tests so no ad code runs.
  static bool enabled = true;

  /// Becomes true once ads may be requested (after consent).
  final ValueNotifier<bool> ready = ValueNotifier<bool>(false);

  bool _started = false;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  DateTime? _lastInterstitial;
  int _lessonCount = 0;

  /// Call once after the first frame. Asks for consent if required, then
  /// starts the Mobile Ads SDK.
  Future<void> start() async {
    if (!enabled || _started) return;
    _started = true;
    try {
      final done = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) {
              if (e != null) debugPrint('Consent form error: ${e.message}');
            });
          } catch (e) {
            debugPrint('Consent form failed: $e');
          }
          if (!done.isCompleted) done.complete();
        },
        (FormError error) {
          debugPrint('Consent info error: ${error.message}');
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future;

      if (await ConsentInformation.instance.canRequestAds()) {
        await MobileAds.instance.initialize();
        ready.value = true;
        _loadInterstitial();
        _loadRewarded();
      }
    } catch (e) {
      debugPrint('Ad start-up failed: $e');
    }
  }

  // ---- Interstitial ----

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: ${error.message}');
          _interstitial = null;
        },
      ),
    );
  }

  /// Shows an interstitial if one is loaded and enough time has passed since
  /// the last one. Completes when the ad is closed (or right away if none).
  Future<void> showInterstitialIfDue() async {
    final ad = _interstitial;
    if (!enabled || !ready.value || ad == null) return;
    final now = DateTime.now();
    final last = _lastInterstitial;
    if (last != null && now.difference(last) < AdConfig.minInterstitialGap) {
      return;
    }
    _interstitial = null;
    _lastInterstitial = now;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
        if (!closed.isCompleted) closed.complete();
      },
    );
    ad.show();
    await closed.future;
  }

  /// Call when the user moves to another lesson page.
  Future<void> onLessonChange() async {
    _lessonCount++;
    if (_lessonCount % AdConfig.lessonsPerInterstitial == 0) {
      await showInterstitialIfDue();
    }
  }

  // ---- Rewarded ----

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: ${error.message}');
          _rewarded = null;
        },
      ),
    );
  }

  /// Shows a rewarded ad. Returns false if no ad was available.
  /// [onReward] runs when the user earns the reward.
  Future<bool> showRewarded({required VoidCallback onReward}) async {
    final ad = _rewarded;
    if (!enabled || !ready.value || ad == null) {
      if (enabled && ready.value) _loadRewarded();
      return false;
    }
    _rewarded = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
        if (!closed.isCompleted) closed.complete();
      },
    );
    ad.show(onUserEarnedReward: (view, reward) => onReward());
    await closed.future;
    return true;
  }
}
