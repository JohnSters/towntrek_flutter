plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

android {
    namespace = "za.co.towntrek.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "za.co.towntrek.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing (required for Google Play uploads)
    // Create `android/key.properties` locally (see `android/key.properties.example`).
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }
    val hasReleaseKeystore = keystorePropertiesFile.exists()
    val isReleaseBuildRequested =
        gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

    // Fail fast (with a clear message) only when a *release* build is requested.
    if (isReleaseBuildRequested && !hasReleaseKeystore) {
        throw GradleException(
            "Release build requested, but android/key.properties was not found. " +
                "Create it from android/key.properties.example (and ensure the keystore path is valid).",
        )
    }

    signingConfigs {
        // Only configure release signing if key.properties exists.
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Allow local non-release tasks (e.g. assembleDebug) to configure without a keystore.
            // When a release task is requested, we fail fast above unless the keystore exists.
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
