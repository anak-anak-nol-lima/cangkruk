//
//  AppButton.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI


struct AppButton: View {
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(label)
                    .foregroundStyle(.white)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}


#Preview {
    AppButton(label: "Button Click") {
        
    }
}
