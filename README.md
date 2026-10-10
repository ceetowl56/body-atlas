# Body Atlas

Anatomy lessons and quizzes (Flutter). Built in sections.

## First-time setup (once, in the cloud builder or on a computer)
This project contains only the Dart code. Generate the Android files with:

    flutter create --org com.yourname --project-name body_atlas --platforms android .

Use your own organisation name instead of `com.yourname`.
This will not overwrite the files in `lib/` or `pubspec.yaml`.

Then add the AdMob settings (test app ID by default):

    sh scripts/setup_android.sh

Then run `flutter pub get` and `flutter run`.

## Ads
- Test ads are ON by default (`lib/ads/ad_config.dart`, `useTestAds = true`).
- For release: create your AdMob app and ad units, paste the real ad unit IDs
  into `ad_config.dart`, set `useTestAds = false`, and run
  `sh scripts/setup_android.sh YOUR_REAL_APP_ID`.
- In AdMob, set up the consent message under Privacy & messaging (GDPR).
- Never click your own live ads.

## Progress
- [x] 1. Project setup
- [x] 2. Content data (JSON): heart, lungs, skeleton
- [x] 3. Lesson screens (list, lessons, search)
- [x] 4. Quiz engine (shuffled questions, feedback, results, saved scores)
- [x] 5. AdMob + consent (banner, interstitial, rewarded 50/50 hint, UMP)
- [x] 6. Release setup (icon, signing, GitHub Actions build, store text, privacy policy)

## Release
See `docs/release_checklist.md` for the full step-by-step guide.
