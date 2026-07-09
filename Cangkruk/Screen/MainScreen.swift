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
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .level:
                        LevelScreen()
                    }
                }
                .environment(router)
        }
    }
}

#Preview {
    MainScreen()
}
