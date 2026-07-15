//
//  AuthFormCard.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct AuthFormCard: View {
    @Binding var username: String
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NAMA PENGGUNA")
                    .font(.shakyComicBold(size: 30))
                    .foregroundStyle(Color("Secondary"))

                TextField("", text: $username)
                    .font(.title3)
                    .foregroundStyle(.black)

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
    @Previewable @State var username = ""
    @Previewable @State var password = ""

    AuthFormCard(username: $username, password: $password)
        .padding()
}

