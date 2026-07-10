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
         manager,
         home
}

@MainActor
@Observable
class RouterViewModel {
    var path = NavigationPath()
    
    func push(_ p: Route) {
        // pushing the path of next navigation page
        path.append(p)
    }
    
    func pop() {
        // go back to previous page
        path.removeLast()
    }
    
    func popToRoot() {
        // jump to first page
        path = NavigationPath()
    }
}
