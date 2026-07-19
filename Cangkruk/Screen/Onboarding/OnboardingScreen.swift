//
//  OnboardingScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI
import SwiftData

struct OnboardingScreen: View {
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    @Environment(AuthenticationViewModel.self) private var authVM
    
    
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    @State private var user: User?
    
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea(.all)
            
            VStack {
                ZStack {
                    AppLottie(animation: "CangkrukHero", placeholder: "CangkrukHero", placeholderHeight: 350)
                        .frame(height: 350)
                    
                    Image("cangkrukHero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .offset(y: -210)
                        .accessibilityLabel("cangkruk")
                }
                
                
                AppButton(label: "Mulai") {
                    router.push(user == nil ? .register : .home)
                }
                .screenPadding()

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
        .onAppear {
            user = authVM.getLastUser(context: modelContext)
        }
    }
}

#Preview {
    OnboardingScreen()
        .environment(RouterViewModel())
        .environment(AuthenticationViewModel())
}
