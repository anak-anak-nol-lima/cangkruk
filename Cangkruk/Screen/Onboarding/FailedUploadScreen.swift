//
//  FailedUploadScreen.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 16/07/26.
//

import SwiftUI

struct FailedUploadScreen: View {
    @Environment(RouterViewModel.self) private var router
    var body: some View {
        
        ZStack{
            Color("Background").ignoresSafeArea(.all)
            VStack{
                Text("SUARA TIDAK").font(.shakyComicBold(size: 40))
                    .foregroundColor(Color("Primary")).bold()
                Text("TEREKAM").font(.shakyComicBold(size: 40)).foregroundColor(Color("Primary")).bold()
                Text("Mau coba lagi?").font(.shakyComicBold(size: 23)).foregroundStyle(Color("Primary"))
                Image("CangkrukNo")
                AppButton(label: "REKAM ULANG"){
                    router.push(.roleplay)
                }
                .padding(.vertical,10)
                .padding(.horizontal, 70)
                
                
            }
        }
    }
}

#Preview{
    FailedUploadScreen()
        .environment(RouterViewModel())
}
