plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.goldenroost.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    val admobAppId = if (keystorePropertiesFile.exists()) {
        (keystoreProperties["admobAppId"] as? String) ?: "ca-app-pub-3940256099942544~3347511713"
    } else {
        "ca-app-pub-3940256099942544~3347511713"
    }

    defaultConfig {
        applicationId = "com.goldenroost.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
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
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                gradle.taskGraph.whenReady {
                    val isReleaseBuild = allTasks.any { task ->
                        task.name.contains("Release", ignoreCase = true) &&
                        (task.name.startsWith("assemble") || task.name.startsWith("bundle"))
                    }
                    if (isReleaseBuild && !keystorePropertiesFile.exists()) {
                        throw GradleException(
                            "CRITICAL RELEASE SIGNING ERROR: android/key.properties is missing!\n" +
                            "Production release builds cannot fall back to debug signing.\n" +
                            "Please provide key.properties with storeFile, storePassword, keyAlias, and keyPassword."
                        )
                    }
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
