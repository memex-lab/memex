plugins {
    id("com.android.library")
}

android {
    namespace = "com.memexlab.memex.agentbackground"
    compileSdk = 36

    defaultConfig {
        minSdk = 26
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
