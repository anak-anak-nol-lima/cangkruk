//
//  AppLottie.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI
import Lottie


struct AppLottie: View {
    var animation: String
    
    var body: some View {
        LottieView(animation: .named(animation))
            .playing()
            .looping()
    }
}


#Preview {
    AppLottie(animation: "CangkrukLay")
}
