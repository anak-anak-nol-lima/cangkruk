//
//  RegisterScreen.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct RegisterScreen: View {
    @Environment(RouterViewModel.self) private var router
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("daftarTitle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 60)

                AuthFormCard(username: $username, password: $password)

                Spacer()
            }
            .padding(24)

            VStack {
                Spacer()

                VStack(spacing: -193) {
                    AppLottie(animation: "CangkrukLay")
                        .frame(height: 500)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)

                    AppImageButton(imageName: "simpanButton") {
                        router.push(.login)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 180)

            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview("Daftar") {
    RegisterScreen()
        .environment(RouterViewModel())
}
