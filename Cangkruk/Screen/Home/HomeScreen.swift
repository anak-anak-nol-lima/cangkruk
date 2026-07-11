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

    var body: some View {
        @Bindable var router = router

        ZStack {
            VStack {
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
                        .onTapGesture {
                            router.push(.register)
                        }
                }
                .padding()

                if !router.isManagerUnlocked {
                    GuestViewScreen()
                }
            }
        }
        .sheet(isPresented: $router.isManagerUnlocked) {
            ManagerView()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
}
