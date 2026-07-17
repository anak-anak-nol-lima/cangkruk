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
            HASIL TES LEVEL 1

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
                    Text("HASIL TES").font(.shakyComicBold(size: 40)).foregroundStyle(Color("Secondary")).padding( 20)
                    Spacer()
                    ShareLink(item: shareText) {
                        Image (systemName: "square.and.arrow.up")
                            .frame (width: 30,height: 40)
                            .background(Color("Primary"))
                            .foregroundStyle(Color(.black))
                            .frame (width: 30,height: 40)
                            .clipShape(Circle())

                            .padding(20)
                            
                    }
                    
                }
                Spacer()
                Image("CangkrukMeditating").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .zIndex(2)
                    .offset(y:60)
                ScrollView{
                    VStack(alignment: .leading, spacing:24){
                        Text("Sumarry:").font(.shakyComicBold(size: 25)).bold()
                        Text(summary).font(.system(size: 16))
                        Text("Feedback").font(.shakyComicBold(size: 25)).bold()
                        Text(feedback).font(.system(size: 16))
                        
                    }
                    
                    .padding(20)
                }.background(Color("lightBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(20)
                AppButton(label:"KEMBALI"){
                    router.push(.level)
                }.padding(.horizontal, 20)
                
            }
            
           
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color("Background"))
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
    ).environment(RouterViewModel())
    
}
