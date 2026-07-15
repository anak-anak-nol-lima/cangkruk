//
//  MainScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI

struct MainScreen: View {
    // MARK: - ViewModel
    @State private var router = RouterViewModel() // route view model to use functionality for dynamic routing
    @State private var notificationViewModel = NotificationViewModel()
    @State private var authenticationViewModel = AuthenticationViewModel()
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack(path: $router.path) {
            OnboardingScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeScreen()
                    case .termsConditions:
                        TermsConditionsScreen()
                    case .register:
                        RegisterScreen()
                    case .login:
                        LoginScreen()
                    case .level:
                        LevelScreen()
                    case .roleplay:
                        RolePlayScreen(isPresented: Binding(
                            get: { true },
                            set: { isPresented in
                                if !isPresented {
                                    router.pop()
                                }
                            }
                        ))
                    }
                }
        }
        .environment(router)
        .environment(notificationViewModel)
        .environment(authenticationViewModel)
    }
}

#Preview {
    MainScreen()
}
