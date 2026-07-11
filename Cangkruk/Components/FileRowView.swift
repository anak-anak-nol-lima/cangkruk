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
        HStack {
            Text(fileName)
                .foregroundStyle(.black)

            Spacer()

            Text(date)
                .foregroundStyle(.black.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black.opacity(0.6), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        FileRowView(fileName: "FileABCDE.pdf", date: "10-10-2026")
        FileRowView(fileName: "FileABCDE.pdf", date: "10-10-2026")
    }
    .padding()
}
