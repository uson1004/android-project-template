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
/*    /**
     * 홈 메뉴 아이템
     */
    data object Home : BottomMenu(
        route = HomeScreenNav,
        icon = R.drawable.ic_home,
        selectedIcon = R.drawable.ic_home_fill,
        title = "홈",
    )

    /**
     * 신청 메뉴 아이템
     */
    data object Application : BottomMenu(
        route = ApplicationScreenNav,
        icon = R.drawable.ic_check_circle,
        selectedIcon = R.drawable.ic_check_circle_fill,
        title = "신청",
    )

    /**
     * 마이페이지 메뉴 아이템
     */
    data object MyPage : BottomMenu(
        route = MyPageScreenNav,
        icon = R.drawable.ic_mypage,
        selectedIcon = R.drawable.ic_mypage_fill,
        title = "마이페이지",
    ) */

    companion object {
        /**
         * 모든 바텀 메뉴 아이템을 순서대로 반환
         *
         * @return 바텀 메뉴 아이템 리스트
         */
        fun values(): List<BottomMenu> = listOf(
//            Home,
//            Application,
//            MyPage,
        )
    }
}
