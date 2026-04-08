import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    val globalKeystoreProperties = Properties()
    val globalKeystorePropertiesFile = rootProject.file("key-global.properties")
    if (globalKeystorePropertiesFile.exists()) {
        globalKeystoreProperties.load(FileInputStream(globalKeystorePropertiesFile))
    }
    val hasGlobalKeystore = globalKeystorePropertiesFile.exists() &&
        globalKeystoreProperties["keyAlias"] != null &&
        globalKeystoreProperties["keyPassword"] != null &&
        globalKeystoreProperties["storeFile"] != null &&
        globalKeystoreProperties["storePassword"] != null

    val cnKeystoreProperties = Properties()
    val cnKeystorePropertiesFile = rootProject.file("key-cn.properties")
    if (cnKeystorePropertiesFile.exists()) {
        cnKeystoreProperties.load(FileInputStream(cnKeystorePropertiesFile))
    }
    val hasCnKeystore = cnKeystorePropertiesFile.exists() &&
        cnKeystoreProperties["keyAlias"] != null &&
        cnKeystoreProperties["keyPassword"] != null &&
        cnKeystoreProperties["storeFile"] != null &&
        cnKeystoreProperties["storePassword"] != null

    namespace = "com.memexlab.memex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.memexlab.memex"
        minSdk = 26  // Required by health plugin 13.2.1
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasGlobalKeystore) {
            create("globalRelease") {
                keyAlias = globalKeystoreProperties["keyAlias"] as String
                keyPassword = globalKeystoreProperties["keyPassword"] as String
                storeFile = file(globalKeystoreProperties["storeFile"] as String)
                storePassword = globalKeystoreProperties["storePassword"] as String
            }
        }
        if (hasCnKeystore) {
            create("cnRelease") {
                keyAlias = cnKeystoreProperties["keyAlias"] as String
                keyPassword = cnKeystoreProperties["keyPassword"] as String
                storeFile = file(cnKeystoreProperties["storeFile"] as String)
                storePassword = cnKeystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "market"
    productFlavors {
        create("global") {
            dimension = "market"
            applicationId = "com.memexlab.memex"
            if (hasGlobalKeystore) {
                signingConfig = signingConfigs.getByName("globalRelease")
            }
        }
        create("cn") {
            dimension = "market"
            applicationId = "com.memexlab.memex.cn"
            if (hasCnKeystore) {
                signingConfig = signingConfigs.getByName("cnRelease")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    applicationVariants.all {
        val variant = this
        outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            output.outputFileName = "memex_${variant.flavorName}_${variant.versionName}_${variant.versionCode}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
    // Official LiteRT-LM Kotlin API (replaces flutter_gemma)
    implementation("com.google.ai.edge.litertlm:litertlm-android:latest.release")
    // Coroutines for async inference
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
    // OkHttp for model downloads (respects system VPN/proxy)
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}