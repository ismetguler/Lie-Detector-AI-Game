import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ismetguler.liededector"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // =================================================================
    // 1. KEYSTORE BİLGİLERİNİ OKUMA
    // =================================================================
    val signingProps = Properties()
    // Dosyayı android/app içinde arar.
    val propertiesFile = file("key.properties") 

    if (propertiesFile.exists()) {
        try {
            signingProps.load(FileInputStream(propertiesFile))
            println("INFO: key.properties dosyası başarıyla yüklendi.")
        } catch (e: Exception) {
            println("HATA: key.properties dosyası okunurken bir hata oluştu: ${e.message}")
        }
    } else {
        println("UYARI: key.properties dosyası 'android/app' klasöründe bulunamadı! Uygulama imzasız olarak derlenecek.")
    }

    // =================================================================
    // 2. DERLEME VE JAVA SÜRÜM AYARLARI
    // =================================================================
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.ismetguler.liededector"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // =================================================================
    // 3. İMZALAMA BİLGİLERİNİ TANIMLAMA (SIGNING CONFIGS)
    // =================================================================
    signingConfigs {
        create("release") {
            val storeFilePath = signingProps["storeFile"] as? String
            
            if (storeFilePath != null && signingProps.containsKey("keyAlias")) {
                storeFile = file(storeFilePath)
                storePassword = signingProps["storePassword"] as String
                keyAlias = signingProps["keyAlias"] as String
                keyPassword = signingProps["keyPassword"] as String
            }
        }
    }

    // =================================================================
    // 4. RELEASE AYARLARI
    // =================================================================
    buildTypes {
        release {
            if (propertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}