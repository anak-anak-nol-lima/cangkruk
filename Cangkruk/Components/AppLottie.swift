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
    
    private func loadAnimation() async throws -> LottieAnimationSource? {
        if let dotLottie = try? await DotLottieFile.named(animation) {
            return dotLottie.animationSource
        }
        
        return LottieAnimation.named(animation)?.animationSource
    }
    
    var body: some View {
        LottieView {
            try await loadAnimation()
        }
        .configuration(LottieConfiguration(renderingEngine: .coreAnimation))
        .playing()
        .looping()
    }
}


#Preview {
    ScrollView {
        VStack {
            AppLottie(animation: "CangkrukLay")
                .frame(height: 400)
            AppLottie(animation: "CangkrukClimb")
                .frame(height: 300)
            AppLottie(animation: "CangkrukWipe")
                .frame(height: 200)
            AppLottie(animation: "CangkrukHero")
                .frame(height: 400)
            AppLottie(animation: "CangkrukMeditate")
                .frame(height: 400)
        }
    }
}
