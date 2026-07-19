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
    @State private var email: String = ""
    @State private var password: String = ""

    private var isResetMode: Bool {
        authVM.resetEmail != nil
    }

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
                    .accessibilityLabel("halaman daftar")

                AuthFormCard(email: $email, password: $password, isEmailEditable: !isResetMode)

                Spacer()
            }
            .padding(24)

            VStack {

                VStack {

                    AppLottie(animation: "CangkrukLay")
                        .frame(height: 200)
                        .allowsHitTesting(false)
                        .offset(y: 25)

                    AppButton(label: "Simpan", isLoading: authVM.isLoading) {
                        Task {
                            if isResetMode {
                                _ = await authVM.resetPassword(context: modelContext, newPassword: password)
                            } else {
                                _ = await authVM.register(context: modelContext, email: email, password: password)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 250)
                .screenPadding()

            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .bottom) {
            if authVM.isError {
                AppSnackbar(errorMessage: authVM.errorMessage ?? "", type: .error, isPresented: $authVM.isError)
            }
        }
        .onAppear {
            if let resetEmail = authVM.resetEmail {
                email = resetEmail
            }
        }
        .onChange(of: authVM.successMessage) { _, newValue in
            switch newValue {
            case "User successfully created":
                router.replacePath(.home)
            case "Password reset successfully":
                router.pop()
            default:
                break
            }
        }
    }
}

#Preview("Daftar") {
    RegisterScreen()
        .environment(RouterViewModel())
        .environment(AuthenticationViewModel())
}
