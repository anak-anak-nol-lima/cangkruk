//
//  OnboardingScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI


struct OnboardingScreen: View {
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea(.all)
            
            VStack {
                ZStack {
                    AppLottie(animation: "CangkrukHero")
                        .frame(height: 350)
                    
                    Image("cangkrukHero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .offset(y: -210)
                }
                
                
                AppImageButton(imageName: "mulaiButton") {
                    router.push(.home)
                }

            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            VStack {
                Text("Data anda hanya akan berada pada HP ini")
                    .font(.caption)
                    .foregroundStyle(Color("Secondary"))
                
                AppButtonText(label: "Syarat & Ketentuan") {
                    router.push(.termsConditions)
                }
            }
        }
    }
}

#Preview {
    OnboardingScreen()
        .environment(RouterViewModel())
}
