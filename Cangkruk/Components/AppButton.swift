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
            .background(Color.black)
            .clipShape(Capsule())
        }
    }
}


struct RecordButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(.red)
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(.white)
                    .frame(width: 105, height: 105)
                Circle()
                    .fill(.red)
                    .frame(width: 90, height: 90)
            }
        }
    }
}


struct AppImageButton: View {
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 46)
        }
    }
}


#Preview {
    AppButton(label: "Button Click") {

    }

    RecordButton() {

    }


    AppImageButton(imageName: "mulaiButton") {

    }
}
