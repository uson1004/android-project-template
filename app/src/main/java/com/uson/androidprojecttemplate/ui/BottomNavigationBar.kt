package com.uson.androidprojecttemplate.ui

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.navigation3.runtime.NavKey

/**
 * 바텀 네비게이션 바 UI 컴포넌트
 *
 * @param currentScreen 현재 선택된 화면의 NavKey
 * @param onNavigate 네비게이션 이벤트 핸들러
 * @param modifier Composable의 Modifier
 * @param containerColor 바텀 네비게이션 바의 배경색
 * @param selectedColor 선택된 아이템의 색상
 * @param unselectedColor 선택되지 않은 아이템의 색상
 * @param cornerRadius 바텀 네비게이션 바의 모서리 둥글기
 * @param menuItems 표시할 메뉴 아이템 리스트 (기본값: BottomMenu.values())
 */
@Composable
fun BottomNavigationBar(
    currentScreen: NavKey?,
    onNavigate: (NavKey) -> Unit,
    modifier: Modifier = Modifier,
    containerColor: Color = MaterialTheme.colorScheme.surface,
    selectedColor: Color = MaterialTheme.colorScheme.primary,
    unselectedColor: Color = MaterialTheme.colorScheme.onSurfaceVariant,
    cornerRadius: Dp = 32.dp,
    menuItems: List<BottomMenu> = BottomMenu.values(),
) {
    BottomAppBar(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = cornerRadius, topEnd = cornerRadius)),
        containerColor = containerColor,
    ) {
        menuItems.forEach { destination ->
            BottomNavigationItem(
                destination = destination,
                selected = currentScreen == destination.route,
                selectedColor = selectedColor,
                unselectedColor = unselectedColor,
                onClick = { onNavigate(destination.route) },
            )
        }
    }
}

/**
 * 바텀 네비게이션 개별 아이템 UI 컴포넌트
 *
 * @param destination 메뉴 아이템 정보
 * @param selected 선택 여부
 * @param selectedColor 선택된 상태의 색상
 * @param unselectedColor 선택되지 않은 상태의 색상
 * @param onClick 클릭 이벤트 핸들러
 * @param iconSize 아이콘 크기
 * @param textStyle 텍스트 스타일
 */
@Composable
private fun RowScope.BottomNavigationItem(
    destination: BottomMenu,
    selected: Boolean,
    selectedColor: Color,
    unselectedColor: Color,
    onClick: () -> Unit,
    iconSize: Dp = 32.dp,
    textStyle: TextStyle = MaterialTheme.typography.labelMedium,
) {
    val color by animateColorAsState(
        targetValue = if (selected) selectedColor else unselectedColor,
        label = "NavigationItemColor",
    )

    NavigationBarItem(
        selected = selected,
        enabled = !selected,
        onClick = onClick,
        colors = NavigationBarItemDefaults.colors(
            indicatorColor = Color.Transparent,
        ),
        icon = {
            BottomNavigationItemContent(
                destination = destination,
                selected = selected,
                color = color,
                iconSize = iconSize,
                textStyle = textStyle,
            )
        },
    )
}

/**
 * 바텀 네비게이션 아이템의 내부 컨텐츠 (아이콘 + 텍스트)
 *
 * @param destination 메뉴 아이템 정보
 * @param selected 선택 여부
 * @param color 현재 색상
 * @param iconSize 아이콘 크기
 * @param textStyle 텍스트 스타일
 */
@Composable
private fun BottomNavigationItemContent(
    destination: BottomMenu,
    selected: Boolean,
    color: Color,
    iconSize: Dp,
    textStyle: TextStyle,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        Icon(
            modifier = Modifier.size(iconSize),
            painter = painterResource(
                id = if (selected) destination.selectedIcon else destination.icon
            ),
            contentDescription = destination.title,
            tint = color,
        )
        Text(
            text = destination.title,
            style = textStyle,
            color = color,
        )
    }
}
