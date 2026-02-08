package com.uson.androidprojecttemplate.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay

@Composable
fun AndroidProjectTemplateApp() {
    val backStack = rememberNavBackStack()

    Box(
        modifier = Modifier.fillMaxSize()
    ) {
        Scaffold(
            bottomBar = {
                BottomNavigationBar(
                    currentScreen = TODO(),
                    onNavigate = TODO(),
                    modifier = TODO(),
                    containerColor = TODO(),
                    selectedColor = TODO(),
                    unselectedColor = TODO(),
                    cornerRadius = TODO(),
                    menuItems = TODO()
                )
            },
            contentWindowInsets = WindowInsets(0),
        ) { paddingValues ->
            NavDisplay(
                modifier = Modifier
                    .padding(paddingValues)
                    .navigationBarsPadding()
                    .statusBarsPadding(),
                backStack = backStack,
                onBack = { backStack.removeLastOrNull() },
                entryDecorators = listOf(
                    rememberSaveableStateHolderNavEntryDecorator(),
                    rememberViewModelStoreNavEntryDecorator(),
                ),
                entryProvider = entryProvider {

                }
            )
        }
    }
}