plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin doit venir après les plugins Android et Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.retrouve_tout"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ requis par les plugins Firebase et autres

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.retrouve_tout"
        minSdk = 23 // ✅ requis par Firebase Auth (au lieu de 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Utilisation de la clé debug pour permettre `flutter run --release`
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
