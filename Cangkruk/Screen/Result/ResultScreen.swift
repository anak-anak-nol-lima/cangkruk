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
    @Environment(\.dismiss) private var dismiss

    
    // MARK: - State
    @State private var isShare: Bool = false
    let isLevelScreen: Bool
    
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
        VStack {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .foregroundStyle(Color("Secondary"))
                    .padding(.bottom, 10)
                    .padding(.leading,10)
                    .onTapGesture {
                        if !isLevelScreen{
                            router.pop()
                        }
                        dismiss()
                    }
                Spacer()
                Text("HASIL TES")
                    .font(.shakyComicBold(size: 43, relativeTo: .body))
                    .foregroundStyle(Color("Primary"))
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
            
            AppLottie(animation: "CangkrukMeditate", placeholder: "CangkrukMeditate", placeholderHeight: 210)
                .frame(height: 250)
                .padding(.bottom, -40)
                .zIndex(1)
            
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Summary")
                            .font(.shakyComicBold(size: 25, relativeTo: .callout))
                        
                        Text(summary)
                            .font(.default)
                    }
                    .padding(.bottom, 32)
                    
                    VStack(alignment: .leading) {
                        Text("Feedback")
                            .font(.shakyComicBold(size: 25, relativeTo: .callout))
                        
                        Text(feedback)
                            .font(.default)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .offset(y: -20)
            
            
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



//#Preview {
//    ResultScreen(
//        summary: "Kamu sudah menunjukkan keramahan yang baik saat menyapa.",
//        feedback: "Tadi kamu langsung bilang \"oke\" tanpa mengulang pesanan. Coba ulangi: \"Jadi, satu Latte dan satu Americano, ya?\""
//    )
//    .environment(RouterViewModel())
//}
