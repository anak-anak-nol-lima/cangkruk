//
//  LoginScreen.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI
import SwiftData

struct LoginScreen: View {
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext

    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    @Environment(AuthenticationViewModel.self) private var authVM

    // MARK: - Local State
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showForgotPassword = false

    var body: some View {
        @Bindable var authVM = authVM
        
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("masukTitle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 60)
                    .accessibilityLabel("halaman masuk")

                AuthFormCard(email: $email, password: $password)

                AppButtonText(label: "Lupa Kata Sandi?") {
                    showForgotPassword = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)

                Spacer()
            }
            .padding(24)

            VStack {
                AppLottie(animation: "CangkrukClimb")
                    .frame(height: 250)
                    .allowsHitTesting(false)
                    .offset(x: 45, y: 125)
                    
                
                AppButton(label: "Masuk", isLoading: authVM.isLoading) {
                    Task {
                        _ = await authVM.login(context: modelContext, email: email, password: password)
                    }
                }
                .screenPadding()
                .padding(.top, 40)
            }
           
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .bottom) {
            if authVM.isError {
                AppSnackbar(errorMessage: authVM.errorMessage ?? "", type: .error, isPresented: $authVM.isError)
            }
        }
        .onChange(of: authVM.successMessage) { _, newValue in
            if newValue == "Login successfully" {
                router.isManagerUnlocked = true
                router.pop()
            }
        }
        .overlay {
            ForgotPasswordAlert(
                isPresented: $showForgotPassword,
                onCheckEmail: { email in
                    authVM.verifyEmailForReset(context: modelContext, email: email)
                },
                onConfirm: { newPassword in
                    Task {
                        _ = await authVM.resetPassword(context: modelContext, newPassword: newPassword)
                    }
                }
            )
        }
    }
}

#Preview("Masuk") {
    LoginScreen()
        .environment(RouterViewModel())
        .environment(AuthenticationViewModel())
}
