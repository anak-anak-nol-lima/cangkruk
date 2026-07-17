//
//  AppLottie.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI
import Lottie


struct AppLottie: View {
    
    // MARK: - Accesibility Built-in
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion
    
    
    var animation: String
    var placeholder: String? = nil
    var placeholderHeight: CGFloat? = 300
    
    private func loadAnimation() async throws -> LottieAnimationSource? {
        let name = animation
        
        return await Task.detached(priority: .userInitiated) {
            if let dotLottie = try? await DotLottieFile.named(animation) {
                return dotLottie.animationSource
            }
            
            return LottieAnimation.named(name)?.animationSource
        }.value
    }
    
    var body: some View {
        LottieView {
            try await loadAnimation()
        } placeholder: {
            if let placeholder {
                Image(placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: placeholderHeight)
            } else {
                ProgressView()
            }
        }
        .configuration(LottieConfiguration(renderingEngine: .coreAnimation))
        .playbackMode(
            accessibilityReduceMotion ? .paused(at: .progress(1)) : .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
        )
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
