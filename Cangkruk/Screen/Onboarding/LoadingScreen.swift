//
//  LoadingScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 15/07/26.
//

import SwiftUI
import SwiftData

struct LoadingScreen:View {

    var body: some View{
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                ZStack{
                    
                    AppLottie(animation: "CangkrukMeditate").frame(height: 240)

                }
                Text("Ntar yak...").font(.shakyComicBold(size: 40)).foregroundStyle(Color("Primary"))
            }
            
        }
    }
}

#Preview {
    LoadingScreen()
}


