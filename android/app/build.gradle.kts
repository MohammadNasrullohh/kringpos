plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kasir"
    compileSdk = 35 // 🔧 Penting agar android:attr/lStar tidak error
    ndkVersion = "29.0.13599879"

    defaultConfig {
        applicationId = "com.example.kasir"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Ubah ke release jika sudah siap rilis
        }
    }
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")
