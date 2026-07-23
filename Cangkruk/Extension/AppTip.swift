//
//  AppTip.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 23/07/26.
//

import SwiftUI

extension View {
    
    // appTip will rendering TIP inside the popover
    // will accept title and message as the words
    // next will be executed as callback when click the button
    func appTip(title: String, message: String, next: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.default)
                .foregroundStyle(Color("Secondary"))
                .bold()
                .padding(.bottom, 4)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 12)
            
            Button {
                next()
            } label: {
                Text("Mengerti")
                    .font(.body)
                    .foregroundStyle(Color("Primary"))
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(30)
        .frame(maxWidth: 270)
        .presentationCompactAdaptation(.popover)
        .interactiveDismissDisabled()
    }
}
