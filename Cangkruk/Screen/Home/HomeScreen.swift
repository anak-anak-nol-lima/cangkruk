//
//  HomeScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI
import SwiftData

struct LevelInfo {
    var level: Int
    var description: String
    var isLock: Bool
}

struct HomeScreen: View {
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    @Environment(AuthenticationViewModel.self) private var authVM
    
    // MARK: - State
    @State private var levelInfo: [LevelInfo] = [
        LevelInfo(level: 1, description: "Pengetahuan akan produk", isLock: false),
        LevelInfo(level: 2, description: "Memahami kebutuhan pelanggan", isLock: false)
    ]
    @State private var user: User?
    @State private var isSOPOpen: Bool = false

    var body: some View {
        @Bindable var router = router

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Tantangan")
                    .font(.title2)
                    .bold()

                Spacer()

                if authVM.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "lock")
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.black)
                        .background(.white)
                        .overlay {
                            Circle()
                                .stroke(.black, lineWidth: 1.5)
                        }
                        .clipShape(Circle())
                        .onTapGesture {
                            router.push(user == nil ? .register : .login)
                        }
                }
            }
            .padding()

            ZStack {
                VStack {
                    ForEach(levelInfo.indices, id: \.self) { idx in
                        let level = levelInfo[idx]

                        AppLevel(level: level.level, description: level.description, isLock: level.isLock, isManager: router.isManagerUnlocked
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
        .onAppear {
            self.user = authVM.getLastUser(context: modelContext)
            self.isSOPOpen = router.isManagerUnlocked
        }
        .sheet(isPresented: $isSOPOpen) {
            ManagerView()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
}
