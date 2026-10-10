# Release checklist (works from a phone)

## A. One-time accounts
1. Google Play Developer account (one-time fee).
2. AdMob account, then create an app (Android) and 3 ad units:
   banner, interstitial, rewarded. Note the App ID and the 3 ad unit IDs.
3. GitHub account, and a new PRIVATE repository for this project.
4. Host the privacy policy at a public URL (for example GitHub Pages or a
   public Google Doc). Fill in the [PLACEHOLDERS] first.

## B. Put the project on GitHub (phone-friendly method)
1. Create a PRIVATE repository. Upload `body_atlas_final.zip` to it as one file.
2. Create `.github/workflows/unpack.yml` with the unpack workflow Claude gave you,
   then run it from the Actions tab. It unzips the project into the repository.
3. GitHub does not let the unpack step create workflow files, so move them by
   hand: open `docs/workflows/build-aab.yml`, tap edit (pencil), change the file
   name box to `.github/workflows/build-aab.yml`, and commit. Repeat for
   `create-keystore.yml`.
4. Open `.github/workflows/build-aab.yml` and change `APP_ORG: com.yourname`
   to your own name BEFORE the first release. It can never be changed after
   publishing.

## C. Create the signing key (once)
1. Actions tab > "Create upload keystore (run once)" > Run workflow.
2. Open the finished run > download the artifact `upload-keystore-SECRET`.
3. In the repository: Settings > Secrets and variables > Actions > New secret.
   Create these secrets (paste the text from the matching file):
   - KEYSTORE_BASE64  (file KEYSTORE_BASE64.txt)
   - KEYSTORE_PASSWORD (file KEYSTORE_PASSWORD.txt)
   - KEY_ALIAS (file KEY_ALIAS.txt, the word "upload")
   - ADMOB_APP_ID (your real AdMob App ID, format ca-app-pub-XXXX~YYYY)
4. Keep a private backup of `upload-keystore.jks`. Never share it or commit it.

## D. Switch to real ads (release only)
1. In `lib/ads/ad_config.dart` paste your 3 real ad unit IDs and set
   `useTestAds = false`.
2. Test on a real phone with test ads FIRST. Never click your own live ads.

## E. Build
1. Actions tab > "Build Android App Bundle" > Run workflow.
2. When it finishes, download the artifact `body-atlas-aab` (contains
   `app-release.aab`). If it fails, copy the error text and send it to Claude.

## F. Upload to Google Play
1. Play Console > Create app. Enable Play App Signing when asked.
2. Fill in store listing (docs/play_store_listing.md), content rating,
   target audience, ads declaration, Data safety.
3. Testing: new personal developer accounts usually must run a closed test
   with a minimum number of testers for a minimum period before production
   access. Check Google's current rule in Play Console and plan for it.
4. Create a release (closed test first), upload the `.aab`, and roll out.
5. After the app is live, link it to your AdMob app (AdMob > App settings >
   Link to Play).

## G. Before each update
Increase the version in `pubspec.yaml` (for example 1.0.1+2: the number after
the + must always go up) and run the build workflow again.
