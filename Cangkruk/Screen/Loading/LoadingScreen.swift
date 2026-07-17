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
    
    var body: some View{
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            
            VStack{
                AppLottie(animation: "CangkrukMeditate", placeholder: "CangkrukMeditate", placeholderHeight: 210)
                    .frame(height: 250)
                
                Text("Ntar yak...").font(.shakyComicBold(size: 40, relativeTo: .title))
                    .foregroundStyle(Color("Primary"))
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


