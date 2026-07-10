//
//  GuestViewScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI



struct GuestViewScreen: View {
    // MARK: - Environment
    @Environment(RouterViewModel.self) private var router
    
    // MARK: - State
    @State private var levelInfo: [LevelInfo] = [
        LevelInfo(level: 1, description: "Pengetahuan akan produk", isLock: false),
        LevelInfo(level: 2, description: "Memahami kebutuhan pelanggan", isLock: false)
    ]
    
    
    var body: some View {
        ZStack {
            VStack {
                // TODO: use proper animation here
                // CangkrukLay should be on MANAGER login
                AppLottie(animation: "CangkrukLay")
                    .frame(height: 250)

                ForEach(levelInfo.indices, id: \.self) { idx in
                    let level = levelInfo[idx]
                    
                    AppLevel(level: level.level, description: level.description, isLock: level.isLock, isManager: false
                    ) {
                        // locking or unlock the app
                        levelInfo[idx].isLock.toggle()
                    } onClick: {
                        // navigation to next screen
                        router.push(.level)
                    }
                }
                
                
                Spacer()
            }
        }
    }
}


#Preview {
    GuestViewScreen()
        .environment(RouterViewModel())
}
