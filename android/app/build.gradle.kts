import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    fun loadKeystoreProperties(fileName: String): Pair<Properties, Boolean> {
        val properties = Properties()
        val propertiesFile = rootProject.file(fileName)
        if (propertiesFile.exists()) {
            properties.load(FileInputStream(propertiesFile))
        }

        val hasRequiredProperties = propertiesFile.exists() &&
            properties["keyAlias"] != null &&
            properties["keyPassword"] != null &&
            properties["storeFile"] != null &&
            properties["storePassword"] != null
        return properties to hasRequiredProperties
    }

    val (globalKeystoreProperties, hasGlobalKeystore) =
        loadKeystoreProperties("key-global.properties")
    val (cnKeystoreProperties, hasCnKeystore) =
        loadKeystoreProperties("key-cn.properties")
    val (earlyKeystoreProperties, hasEarlyKeystore) =
        loadKeystoreProperties("key-early.properties")

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
        if (hasEarlyKeystore) {
            create("earlyRelease") {
                keyAlias = earlyKeystoreProperties["keyAlias"] as String
                keyPassword = earlyKeystoreProperties["keyPassword"] as String
                storeFile = file(earlyKeystoreProperties["storeFile"] as String)
                storePassword = earlyKeystoreProperties["storePassword"] as String
            }
        }
    }

    val globalApplicationId = "com.memexlab.memex"
    val cnApplicationId = "com.memexlab.memex.cn"
    val globalEarlyApplicationId = "com.memexlab.memex.early"
    val cnEarlyApplicationId = "com.memexlab.memex.cn.early"
    val globalDevApplicationId = "com.memexlab.memex.dev"
    val cnDevApplicationId = "com.memexlab.memex.cn.dev"

    flavorDimensions += "market"
    productFlavors {
        create("global") {
            dimension = "market"
            applicationId = globalApplicationId
            manifestPlaceholders["appLabel"] = "Memex"
            resValue("string", "quick_action_target_package", globalApplicationId)
            if (hasGlobalKeystore) {
                signingConfig = signingConfigs.getByName("globalRelease")
            }
        }
        create("cn") {
            dimension = "market"
            applicationId = cnApplicationId
            manifestPlaceholders["appLabel"] = "Memex"
            resValue("string", "quick_action_target_package", cnApplicationId)
            if (hasCnKeystore) {
                signingConfig = signingConfigs.getByName("cnRelease")
            }
        }
        create("globalEarly") {
            dimension = "market"
            applicationId = globalEarlyApplicationId
            manifestPlaceholders["appLabel"] = "Memex Early"
            resValue(
                "string",
                "quick_action_target_package",
                globalEarlyApplicationId,
            )
            if (hasEarlyKeystore) {
                signingConfig = signingConfigs.getByName("earlyRelease")
            }
        }
        create("cnEarly") {
            dimension = "market"
            applicationId = cnEarlyApplicationId
            manifestPlaceholders["appLabel"] = "Memex Early CN"
            resValue("string", "quick_action_target_package", cnEarlyApplicationId)
            if (hasEarlyKeystore) {
                signingConfig = signingConfigs.getByName("earlyRelease")
            }
        }
        create("globalDev") {
            dimension = "market"
            applicationId = globalDevApplicationId
            manifestPlaceholders["appLabel"] = "Memex Dev"
            resValue("string", "quick_action_target_package", globalDevApplicationId)
        }
        create("cnDev") {
            dimension = "market"
            applicationId = cnDevApplicationId
            manifestPlaceholders["appLabel"] = "Memex Dev CN"
            resValue("string", "quick_action_target_package", cnDevApplicationId)
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
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
}
