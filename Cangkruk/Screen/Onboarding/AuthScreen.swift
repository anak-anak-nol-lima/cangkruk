//
//  AuthScreen.swift
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

                    AppImageButton(imageName: "simpanButton") {
                        // TODO: validate/persist registration before moving on
                        router.push(.login)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 180)

            }
        }
    }
}

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
                            .frame(width: 300, height: 300)
                            .offset(x: 20, y: 210)
                    }

                Spacer()
            }
            .padding(24)

            VStack {
                Spacer()

                AppImageButton(imageName: "masukButton") {
                    // TODO: hook up login action
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 180)
            }
        }
    }
}

private struct AuthFormCard: View {
    @Binding var username: String
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Image("namaPenggunaLabel")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                TextField("", text: $username)
                    .font(.title3)
                    .foregroundStyle(.black)

                Rectangle()
                    .fill(Color("Primary"))
                    .frame(height: 1.5)
            }

            VStack(alignment: .leading, spacing: 8) {
                Image("passwordLabel")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

                SecureField("", text: $password)
                    .font(.title3)
                    .foregroundStyle(.black)

                Rectangle()
                    .fill(Color("Primary"))
                    .frame(height: 1.5)
            }
        }
        .padding(32)
        .background(Color(red: 1.0, green: 250 / 255, blue: 240 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 5)
    }
}

#Preview("Daftar") {
    RegisterScreen()
        .environment(RouterViewModel())
}

#Preview("Masuk") {
    LoginScreen()
        .environment(RouterViewModel())
}
