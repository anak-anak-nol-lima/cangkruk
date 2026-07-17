//
//  ResultScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import SwiftUI

struct ResultScreen: View {
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    
    // MARK: - State
    @State private var isShare: Bool = false
    
    
    // MARK: - Property
    let summary: String
    let feedback: String
    
    private var shareText: String {
            """
            Hasil Tes
            
            Summary:
            \(summary)
            
            Feedback:
            \(feedback)
            """
    }
    
    
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    Text("Hasil Tes")
                        .font(.shakyComicBold(size: 40, relativeTo: .title3))
                        .foregroundStyle(Color("Secondary"))
                        .padding()
                    
                    Spacer()
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .padding(10)
                            .font(.title2)
                            .background(Color("Primary"))
                            .foregroundStyle(Color("Background"))
                            .clipShape(Circle())
                            .padding()
                            .accessibilityLabel("Share Hasil Tes")
                    }
                    .disabled(isShare)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            isShare = true
                            
                            Task {
                                try? await Task.sleep(for: .seconds(2))
                                isShare = false
                            }
                        }
                    )
                }
                
                Spacer()
            }
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading){
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary:")
                                .font(.shakyComicBold(size: 25, relativeTo: .body))
                                .bold()
                            Text(summary)
                                .font(.default)
                        }
                        .padding(.bottom, 32)
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Feedback")
                                .font(.shakyComicBold(size: 25, relativeTo: .body)).bold()
                            Text(feedback)
                                .font(.default)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .background(Color("lightBackground"))
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .padding()
                .padding(.bottom, 100)
                .padding(.top, 200)

            }
            .overlay(alignment: .top) {
                AppLottie(animation: "CangkrukMeditate")
                    .frame(width: 200, height: 200)
                    .zIndex(1)
                    .accessibilityLabel("Foto Cangkruk Meditasi")
                    .offset(y: 50)
            }
            
            VStack {
                Spacer()
                
                AppButton(label: "Kembali") {
                    router.push(.level)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
    }
}

struct SharePhoto: Transferable {
    let image: Image
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
}

#Preview {
    ResultScreen(
        summary: "Kamu sudah menunjukkan keramahan yang baik saat menyapa.",
        feedback: "Tadi kamu langsung bilang \"oke\" tanpa mengulang pesanan. Coba ulangi: \"Jadi, satu Latte dan satu Americano, ya?\""
    )
    .environment(RouterViewModel())
}
