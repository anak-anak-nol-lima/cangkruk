//
//  LoadingScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 15/07/26.
//

import SwiftUI
import SwiftData

struct LoadingScreen: View {
    var action: () -> Void
    @State var countDots: Int = 0
    
    var body: some View{
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            
            VStack{
                AppLottie(animation: "CangkrukMeditate", placeholder: "CangkrukMeditate", placeholderHeight: 210)
                    .frame(height: 250)
                
                HStack {
                    Text("Ntar yak")
                        .font(.shakyComicBold(size: 40, relativeTo: .title))
                        .foregroundStyle(Color("Primary"))
                    Text(String(repeating: ". ", count: countDots))
                        .font(.shakyComicBold(size: 40, relativeTo: .title))
                        .foregroundStyle(Color("Primary"))
                        .task {
                            while true {
                                // when the page loaded
                                // we add the dots counter
                                try? await Task.sleep(for: .seconds(0.4))
                                countDots = (countDots + 1) % 4
                            }
                        }
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            action()
        }
    }
}

#Preview {
    LoadingScreen() {

    }
}


