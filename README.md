# towntrek_flutter

A Flutter project for the TownTrek mobile app.

## Environment (local vs Azure production)

The backend API base URL is configured in `lib/core/config/api_config.dart`.

- **Debug** defaults to local (`localHost`)
- **Profile/Release** defaults to production (Azure)

You can override without changing code using `--dart-define`:
- **Force production**: `--dart-define=TT_ENV=production`
- **Force local**: `--dart-define=TT_ENV=localHost`
- **Force a specific API host** (highest priority): `--dart-define=TT_API_BASE_URL=https://your-api-host`

## Dependency notes

- **Mapbox (Android build)**: `mapbox_maps_flutter` is **pinned** in `pubspec.yaml` because newer versions were causing Kotlin compilation failures during Android builds under the current Android toolchain. If you upgrade it, validate with `flutter build apk`.

## Google Play (Internal Testing) – Release signing

Google Play will reject artifacts signed with the **debug** key. Configure a **release/upload keystore**:

- Note: **Debug builds do not require** `android/key.properties`. **Release builds will fail** if it’s missing.

- **1) Generate an upload keystore** (Windows PowerShell):

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- **2) Move the keystore** to `towntrek_flutter/keystore/upload-keystore.jks` (create the folder if needed).
- **3) Create** `towntrek_flutter/android/key.properties` (this file is gitignored) by copying `android/key.properties.example` and setting passwords.
- **4) Build a Play-ready bundle**:

```powershell
flutter build appbundle --release --dart-define=TT_ENV=production
```

This produces: `build/app/outputs/bundle/release/app-release.aab`