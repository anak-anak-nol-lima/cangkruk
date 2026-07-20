//
//  HasilScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import SwiftUI

struct HasilScreen: View {
    
    @Environment(RouterViewModel.self) private var router
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
            VStack{
                HStack{
                    Text("Hasil Tes")
                        .font(.shakyComicBold(size: 40))
                        .foregroundStyle(Color("Secondary"))
                        .padding(20)
                    Spacer()
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 40,height: 40)
                            .background(Color("Primary"))
                            .foregroundStyle(Color("Background"))
                            .clipShape(Circle())
                            .padding(20)
                            .accessibilityLabel("Share Hasil Tes")
                    }
                }
                Spacer()
                
                VStack(spacing: -80) {
                    AppLottie(animation: "CangkrukMeditate")
                        .frame(width: 200, height: 200)
                        .zIndex(1)
                        .accessibilityLabel("Foto Cangkruk Menari")
                        .offset(y: -30)
                    
                    ScrollView{
                        VStack(alignment: .leading, spacing:24){
                            Text("Summary:")
                                .font(.shakyComicBold(size: 25))
                                .bold()
                            Text(summary)
                                .font(.system(size: 16))
                            
                            Text("Feedback")
                                .font(.shakyComicBold(size: 25)).bold()
                            Text(feedback)
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                    }
                    .background(Color("lightBackground"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .padding(20)
                }
                
                AppButton(label: "Kembali") {
                    router.push(.level(1))
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
    HasilScreen(
        summary: "Kamu sudah menunjukkan keramahan yang baik saat menyapa.",
        feedback: "Tadi kamu langsung bilang \"oke\" tanpa mengulang pesanan. Coba ulangi: \"Jadi, satu Latte dan satu Americano, ya?\""
    )
    .environment(RouterViewModel())
}
