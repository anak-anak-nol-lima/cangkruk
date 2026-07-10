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
    // MARK: - State
    
    // TODO: please update this into proper viewModel
    @State private var isManager: Bool = false
    
    var body: some View {
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
                }
                .padding()
                
                if isManager {
                    EmptyView()
                } else {
                    GuestViewScreen()
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
}
