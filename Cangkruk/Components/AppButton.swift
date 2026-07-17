//
//  AppButton.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI


struct AppButton: View {
    var label: String
    var isLoading: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button {
            if !isLoading {
                action()
            }
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    Text(label)
                        .foregroundStyle(.white)
                        .bold()
                        .font(.shakyComicBold(size: 31))
                        .textCase(.uppercase)
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)
            .background(isLoading ? .gray : Color("Primary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    Image(imageName)
                }
            }
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
