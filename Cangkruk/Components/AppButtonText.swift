//
//  AppButtonText.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct AppButtonText: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("Primary"))
        }
    }
}


#Preview {
    AppButtonText(label: "Syarat & Ketentuan") {

    }
}
