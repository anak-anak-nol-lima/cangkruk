//
//  AuthFormCard.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct AuthFormCard: View {
    @Binding var email: String
    @Binding var password: String
    var isEmailEditable: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("EMAIL")
                    .font(.shakyComicBold(size: 30))
                    .foregroundStyle(Color("Secondary"))

                TextField("", text: $email)
                    .font(.title3)
                    .foregroundStyle(.black)
                    .disabled(!isEmailEditable)
                    .opacity(isEmailEditable ? 1 : 0.6)

                Rectangle()
                    .fill(Color("Primary"))
                    .frame(height: 1.5)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("KATA SANDI")
                    .font(.shakyComicBold(size: 30))
                    .foregroundStyle(Color("Secondary"))

                SecureField("", text: $password)
                    .font(.title3)
                    .foregroundStyle(.black)

                Rectangle()
                    .fill(Color("Primary"))
                    .frame(height: 1.5)
            }
        }
        .padding(32)
        .background(Color("lightBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 5)
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""

    AuthFormCard(email: $email, password: $password)
        .padding()
}

