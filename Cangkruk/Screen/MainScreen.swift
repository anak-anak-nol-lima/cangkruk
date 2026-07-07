//
//  MainScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI

struct MainScreen: View {
    @State private var pageStateVM = PageStateViewModel()
    
    var body: some View {
        switch pageStateVM.currentPage {
        case .home:
            HomeScreen()
        case .detail:
            Text("Detail Screen")
        }
    }
}

#Preview {
    MainScreen()
}
