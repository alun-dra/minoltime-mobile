import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (!keystorePropertiesFile.exists()) {
    throw GradleException("No se encontró android/key.properties")
}

keystoreProperties.load(FileInputStream(keystorePropertiesFile))

val storePasswordValue = keystoreProperties.getProperty("storePassword")
    ?: throw GradleException("Falta storePassword en key.properties")

val keyPasswordValue = keystoreProperties.getProperty("keyPassword")
    ?: throw GradleException("Falta keyPassword en key.properties")

val keyAliasValue = keystoreProperties.getProperty("keyAlias")
    ?: throw GradleException("Falta keyAlias en key.properties")

val storeFileValue = keystoreProperties.getProperty("storeFile")
    ?: throw GradleException("Falta storeFile en key.properties")

android {
    namespace = "cl.minoltime.app"
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
        applicationId = "cl.minoltime.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
            storeFile = rootProject.file(storeFileValue)
            storePassword = storePasswordValue
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}