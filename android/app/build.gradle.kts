plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kinjalanchhara.jarvis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358" // Pinned — matches flutter.ndkVersion for Flutter 3.41.2

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kinjalanchhara.jarvis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- Flavor configuration ---
    // Each flavor maps to an environment: dev, staging, prod.
    // All three can be installed simultaneously on the same device during development
    // because they have distinct application IDs.
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Jarvis Dev")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Jarvis Staging")
        }
        create("prod") {
            dimension = "env"
            // No suffix — this is the real app users download
            resValue("string", "app_name", "Jarvis")
        }
    }

    buildTypes {
        release {
            // TODO: Replace with a real signing config before Play Store submission (Phase 5)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
