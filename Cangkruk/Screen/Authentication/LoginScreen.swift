//
//  LoginScreen.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct LoginScreen: View {
    @Environment(RouterViewModel.self) private var router
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("masukTitle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 60)

                AuthFormCard(username: $username, password: $password)
                    .overlay(alignment: .bottomTrailing) {
                        AppLottie(animation: "CangkrukClimb")
                            .frame(height: 300)
                            .offset(x: 50, y: 205)
                            .allowsHitTesting(false)
                        
                    }

                Spacer()
            }
            .padding(24)

            VStack {
                Spacer()

                AppImageButton(imageName: "masukButton") {
                    // TODO: validate credentials before unlocking manager mode
                    router.isManagerUnlocked = true
                    router.pop(2) // pop Login + Register, landing back on HomeScreen
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 230)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview("Masuk") {
    LoginScreen()
        .environment(RouterViewModel())
}
