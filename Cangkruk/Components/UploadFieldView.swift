//
//  UploadFieldView.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import SwiftUI

struct UploadFieldView: View {
    var fileName: String?
    var placeholder: String = "Unggah file"
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)

            Text(fileName ?? placeholder)
                .foregroundStyle(fileName == nil ? .secondary : .primary)

            Spacer()

            Button(action: action) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        UploadFieldView(fileName: "File_SOP.pdf") {}
        UploadFieldView(fileName: nil) {}
    }
    .padding()
}
