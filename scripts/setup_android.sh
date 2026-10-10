#!/bin/sh
# Run once, after `flutter create ... --platforms android .`
# Usage: sh scripts/setup_android.sh [ADMOB_APP_ID]
# With no argument it uses Google's TEST app ID (safe for development).
# For release, pass your real AdMob App ID (format ca-app-pub-XXXX~YYYY).
set -e
APP_ID="${1:-ca-app-pub-3940256099942544~3347511713}"
MANIFEST=android/app/src/main/AndroidManifest.xml

if [ ! -f "$MANIFEST" ]; then
  echo "Cannot find $MANIFEST. Run 'flutter create' first."
  exit 1
fi

# 1) AdMob app ID in the manifest
if grep -q "com.google.android.gms.ads.APPLICATION_ID" "$MANIFEST"; then
  sed -i "s#\(com.google.android.gms.ads.APPLICATION_ID\"[^>]*android:value=\"\)[^\"]*#\1$APP_ID#" "$MANIFEST"
  echo "Updated AdMob app ID."
else
  sed -i "s#</application>#    <meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"$APP_ID\"/>\n    </application>#" "$MANIFEST"
  echo "Added AdMob app ID."
fi

# 2) App name shown on the phone
sed -i 's/android:label="body_atlas"/android:label="Body Atlas"/' "$MANIFEST"

# 3) minSdk 23 (needed by the ads plugin)
for f in android/app/build.gradle.kts android/app/build.gradle; do
  if [ -f "$f" ]; then
    sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 24/; s/minSdkVersion flutter.minSdkVersion/minSdkVersion 24/' "$f"
    echo "Checked minSdk in $f"
  fi
done
echo "Android setup done."
