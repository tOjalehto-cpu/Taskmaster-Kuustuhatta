plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.taskmaster_kuustuhatta"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" //flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11 // Päivitetty versioon 11
        targetCompatibility = JavaVersion.VERSION_11 // Päivitetty versioon 11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11" // Päivitetty versioon 11
    }

    defaultConfig {
        applicationId = "com.example.taskmaster_kuustuhatta"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Käytä coreLibraryDesugaring-konfiguraatiota
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}