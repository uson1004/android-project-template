package com.uson.androidprojecttemplate.navigation

import androidx.navigation3.runtime.NavKey

/**
 * 앱 내 모든 네비게이션 대상을 정의하는 sealed class
 */
sealed interface NavigationRoute : NavKey {
    data object Splash : NavigationRoute
    data object Home : NavigationRoute
    data object Application : NavigationRoute
    data object MyPage : NavigationRoute
}