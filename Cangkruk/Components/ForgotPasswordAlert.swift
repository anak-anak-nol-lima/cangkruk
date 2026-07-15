//
//  ForgotPasswordAlert.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 14/07/26.
//

import SwiftUI

struct ForgotPasswordAlert: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""

    var onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                    .zIndex(1)

                VStack(alignment: .leading, spacing: 16) {
                    Text("LUPA KATA SANDI")
                        .font(.shakyComicBold(size: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color("Secondary"))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.shakyComicBold(size: 22))
                            .foregroundStyle(Color("Secondary"))

                        TextField("", text: $email)
                            .font(.title3)
                            .foregroundStyle(.black)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        Rectangle()
                            .fill(Color("Primary"))
                            .frame(height: 1.5)
                    }

                    Button {
                        onSubmit(email)
                        isPresented = false
                    } label: {
                        Text("CEK EMAIL")
                            .font(.shakyComicBold(size: 20))
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
}

#Preview {
    @Previewable @State var isPresented = true

    ForgotPasswordAlert(isPresented: $isPresented) { email in
        print("Cek email: \(email)")
    }
}
