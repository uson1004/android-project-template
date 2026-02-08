plugins {
    id(libs.plugins.android.library.get().pluginId)
    id(libs.plugins.kotlin.android.get().pluginId)
    id(libs.plugins.kotlin.ksp.get().pluginId)
}

apply<CommonGradlePlugin>()

android {
    namespace = "com.yuseob.android.core.network"
}