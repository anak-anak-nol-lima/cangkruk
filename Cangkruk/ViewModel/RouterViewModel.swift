//
//  RouterViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI

enum Route {
    case level,
         roleplay,
         home,
         termsConditions,
         register,
         login
}

@MainActor
@Observable
class RouterViewModel {
    var path = NavigationPath()

    // Set to true once register + login succeed; HomeScreen observes this to reveal ManagerView.
    var isManagerUnlocked = false

    func push(_ p: Route) {
        // pushing the path of next navigation page
        path.append(p)
    }

    func pop(_ count: Int = 1) {
        // go back `count` pages
        path.removeLast(min(count, path.count))
    }

    func popToRoot() {
        // jump to first page
        path = NavigationPath()
    }
    
    
    func replacePath(_ p: Route) {
        // replace current path with next path
        if !path.isEmpty {
            path.removeLast()
        }
        
        path.append(p)
    }
}
