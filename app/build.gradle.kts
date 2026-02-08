import org.gradle.kotlin.dsl.ksp

@Suppress("DSL_SCOPE_VIOLATION") // TODO: Remove once KTIJ-19369 is fixed
plugins {
    id(libs.plugins.android.application.get().pluginId)
    id(libs.plugins.kotlin.android.get().pluginId)
    id(libs.plugins.hilt.android.get().pluginId)
    id(libs.plugins.kotlin.ksp.get().pluginId)
}

android {
    namespace = "com.uson.androidprojecttemplate" // 패키지 네임스페이스 정의
    defaultConfig {
        applicationId = "com.uson.androidprojecttemplate" // Override default from plugin
        versionCode = ProjectProperties.VERSION_CODE
        versionName = ProjectProperties.VERSION_NAME
        compileSdk = ProjectProperties.COMPILE_SDK
        minSdk = ProjectProperties.MIN_SDK
        targetSdk = ProjectProperties.TARGET_SDK // Override default from plugin
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_18
        targetCompatibility = JavaVersion.VERSION_18
    }
    kotlinOptions {
        jvmTarget = ProjectProperties.JVM_TARGET
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = ProjectProperties.COMPOSE_VERSION
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.navigation)

    implementation(libs.hilt.android)
    implementation(libs.androidx.hilt.navigation.compose)
    ksp(libs.hilt.android.compiler)

    implementation(project(":core:ui"))
    implementation(project(":core:design-system"))
    implementation(project(":core:data"))
    implementation(project(":core:domain"))
    implementation(project(":core:common"))
}