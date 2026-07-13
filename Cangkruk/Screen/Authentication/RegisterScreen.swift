//
//  RegisterScreen.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI
import SwiftData


struct RegisterScreen: View {
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    @Environment(AuthenticationViewModel.self) private var authVM
    
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Local State
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        @Bindable var authVM = authVM

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
                        .frame(height: 200)
                        .offset(y: -175)
                        .allowsHitTesting(false)

                    AppImageButton(imageName: "simpanButton", isLoading: authVM.isLoading) {
                        Task {
                            _ = await authVM.register(context: modelContext, username: username, password: password)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 180)

            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .bottom) {
            if authVM.isError {
                AppSnackbar(errorMessage: authVM.errorMessage ?? "", type: .error, isPresented: $authVM.isError)
            }
        }
        .onChange(of: authVM.successMessage) { _, newValue in
            if newValue != "" {
                router.replacePath(.login)
            }
        }
    }
}

#Preview("Daftar") {
    RegisterScreen()
        .environment(RouterViewModel())
        .environment(AuthenticationViewModel())
}
