//
//  UploadFieldView.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import SwiftUI

struct UploadFieldView: View {
    var titleAsset: String
    var action: () -> Void

    var body: some View {
        HStack {
            Image(titleAsset)
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            Spacer()

            Button(action: action) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color("Primary"))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    UploadFieldView(titleAsset: "sopSectionTitle") {}
        .padding()
}
