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
        .background(Color("lightBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 5)
    }
}


