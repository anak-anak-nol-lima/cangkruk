//
//  HomeScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI

struct LevelInfo {
    var level: Int
    var description: String
    var isLock: Bool
}

struct HomeScreen: View {
    // MARK: - Environment
    @Environment(RouterViewModel.self) private var router
    
    // MARK: - State
    @State private var levelInfo: [LevelInfo] = [
        LevelInfo(level: 1, description: "Pengetahuan akan produk", isLock: false),
        LevelInfo(level: 2, description: "Memahami kebutuhan pelanggan", isLock: false)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Tantangan")
                    .font(.title2)
                    .bold()

                Spacer()

                Image(systemName: "lock")
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.black)
                    .background(.white)
                    .overlay {
                        Circle()
                            .stroke(.black, lineWidth: 1.5)
                    }
                    .clipShape(Circle())
            }
            .padding()

            ZStack {
                VStack {
                    ForEach(levelInfo.indices, id: \.self) { idx in
                        let level = levelInfo[idx]

                        AppLevel(level: level.level, description: level.description, isLock: level.isLock, isManager: true
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
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
}
