#!/bin/sh
set -e
APP_ID="${1:-ca-app-pub-3940256099942544~3347511713}"
APP_ID=$(printf '%s' "$APP_ID" | tr -d ' \r\n')
case "$APP_ID" in
  ca-app-pub-????????????????~??????????) ;;
  *)
    echo "Invalid AdMob app ID, using Google test ID instead."
    APP_ID="ca-app-pub-3940256099942544~3347511713"
    ;;
esac
MANIFEST=android/app/src/main/AndroidManifest.xml

if [ ! -f "$MANIFEST" ]; then
  echo "Cannot find $MANIFEST. Run 'flutter create' first."
  exit 1
fi

if grep -q "com.google.android.gms.ads.APPLICATION_ID" "$MANIFEST"; then
  sed -i "s#\(com.google.android.gms.ads.APPLICATION_ID\"[^>]*android:value=\"\)[^\"]*#\1$APP_ID#" "$MANIFEST"
  echo "Updated AdMob app ID."
else
  sed -i "s#</application>#    <meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"$APP_ID\"/>\n    </application>#" "$MANIFEST"
  echo "Added AdMob app ID."
fi

sed -i 's/android:label="body_atlas"/android:label="Body Atlas"/' "$MANIFEST"

for f in android/app/build.gradle.kts android/app/build.gradle; do
  if [ -f "$f" ]; then
    sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 24/; s/minSdkVersion flutter.minSdkVersion/minSdkVersion 24/' "$f"
    echo "Checked minSdk in $f"
  fi
done

echo "--- Manifest check ---"
grep -n "APPLICATION_ID" "$MANIFEST" || echo "AdMob ID NOT FOUND"
echo "Android setup done."
