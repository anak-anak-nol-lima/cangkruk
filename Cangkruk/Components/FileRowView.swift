//
//  FileRowView.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import SwiftUI

struct FileRowView: View {
    var fileName: String
    var date: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)

            Text(fileName)

            Spacer()

            Text(date)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        FileRowView(fileName: "FileABCDE.pdf", date: "2024-10-27")
        FileRowView(fileName: "FileABCDE.pdf", date: "2024-10-27")
    }
    .padding()
}
