//
//  ForgotPasswordAlert.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 14/07/26.
//

import SwiftUI

struct ForgotPasswordAlert: View {
    @Binding var isPresented: Bool

    @State private var step = 1
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var errorText: String = ""

    var onCheckEmail: (String) -> Bool
    var onConfirm: (String) -> Void

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }
                    .zIndex(1)

                VStack(alignment: .leading, spacing: 16) {
                    Text("LUPA KATA SANDI")
                        .font(.shakyComicBold(size: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Secondary"))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.shakyComicBold(size: 22, relativeTo: .subheadline))
                            .foregroundStyle(Color("Secondary"))

                        if !errorText.isEmpty {
                            Text(errorText)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        actionButton("CEK EMAIL") {
                            if onCheckEmail(email) {
                                errorText = ""
                                step = 2
                            } else {
                                errorText = "Email tidak ditemukan"
                            }
                        }
                    } else {
                        inputField(label: "KATA SANDI BARU", text: $newPassword, isSecure: true)

                    Button {
                        onSubmit(email)
                        isPresented = false
                    } label: {
                        Text("CEK EMAIL")
                            .font(.shakyComicBold(size: 20, relativeTo: .headline))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color("Primary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(24)
                .background(Color("lightBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 40)
                .zIndex(2)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
    }

    private func close() {
        isPresented = false
        step = 1
        email = ""
        newPassword = ""
        errorText = ""
    }

    @ViewBuilder
    private func inputField(label: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.shakyComicBold(size: 22))
                .foregroundStyle(Color("Secondary"))

            if isSecure {
                SecureField("", text: text)
                    .font(.title3)
                    .foregroundStyle(.black)
            } else {
                TextField("", text: text)
                    .font(.title3)
                    .foregroundStyle(.black)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Rectangle()
                .fill(Color("Primary"))
                .frame(height: 1.5)
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.shakyComicBold(size: 20))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color("Primary"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    ForgotPasswordAlert(
        isPresented: $isPresented,
        onCheckEmail: { email in email == "tes@cangkruk.com" },
        onConfirm: { newPassword in print("Sandi baru: \(newPassword)") }
    )
}
