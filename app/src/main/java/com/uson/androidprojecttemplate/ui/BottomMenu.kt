package com.uson.androidprojecttemplate.ui

import androidx.annotation.DrawableRes
import androidx.navigation3.runtime.NavKey

/**
 * 바텀 네비게이션 메뉴 아이템을 정의하는 sealed class
 *
 * @property route 네비게이션 라우트 키
 * @property icon 선택되지 않은 상태의 아이콘 리소스
 * @property selectedIcon 선택된 상태의 아이콘 리소스
 * @property title 메뉴 아이템의 제목
 */
sealed class BottomMenu(
    val route: NavKey,
    @DrawableRes val icon: Int,
    @DrawableRes val selectedIcon: Int,
    val title: String,
) {
    // TODO: 바텀 메뉴 아이템 정의
    // 예시:
    // data object Home : BottomMenu(
    //     route = HomeScreenNav,
    //     icon = R.drawable.ic_home,
    //     selectedIcon = R.drawable.ic_home_fill,
    //     title = "홈",
    // )
    companion object {
        /**
         * 모든 바텀 메뉴 아이템을 순서대로 반환
         *
         * @return 바텀 메뉴 아이템 리스트
         */
        fun values(): List<BottomMenu> = TODO("정의된 메뉴 아이템 리스트 반환")
    }
}
