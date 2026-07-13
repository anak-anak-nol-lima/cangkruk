//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

struct LevelScreen: View {
    
    // MARK: - State
    @State private var isRolePlaying: Bool = false
    @Environment(RouterViewModel.self) private var router
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    HStack {
                        Text("LEVEL 1")
                            .font(.shakyComicBold(size: 50))
                            .bold()
                            .foregroundStyle(Color("Secondary"))
                        
                        Spacer()
                        
                        Button {
                            router.pop()
                        } label: {
                            Image(systemName: "arrow.uturn.left.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                                .foregroundStyle(Color("Primary"))
                                .padding(.bottom, 10)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    AppLottie(animation: "CangkrukWipe")
                        .frame(width: 185)
                        .offset(x: -30, y: -35)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .zIndex(1)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        moduleSection(
                            title: "PRODUK MENU",
                            content: "Langkah pertama sebagai barista adalah mengenal produk yang dijual. Secara umum, menu dibagi menjadi beberapa kategori:\n\nKopi berbasis espresso Espresso, Americano, Cappuccino, Latte, dan variasinya. Semua berawal dari espresso sebagai basis rasa; yang membedakan adalah takaran air dan susunya.\n\nManual brew kopi seduh manual seperti V60, Tubruk, dan Cold Brew. Fokusnya menonjolkan karakter dan notes dari biji kopi.\n\nMinuman non-kopi cokelat, matcha, dan teh, untuk pelanggan yang tidak minum kopi.\n\nYang perlu kamu kuasai di tahap ini: nama produk, bahan utamanya, dan bedanya minuman milk-based vs non-milk."
                        )
                        moduleSection(
                            title: "SOP",
                            content: "SOP adalah panduan langkah kerja yang wajib diikuti agar kualitas dan pelayanan tetap konsisten di setiap shift, siapa pun baristanya.\n\nSebelum buka bersihkan area bar, cek & kalibrasi mesin, siapkan bahan (susu, sirup, biji kopi).\n\nSaat melayani sapa pelanggan dengan ramah, konfirmasi pesanan, dan buat sesuai resep baku.\n\nSebelum menyajikan untuk manual brew, cicipi dulu hasilnya sebelum diberikan ke pelanggan.\n\nSetelah shift catat stok, bersihkan alat, dan lakukan handover ke shift berikutnya.\n\nIntinya: SOP memastikan setiap cangkir punya rasa dan kualitas yang sama."
                        )
                    }
                    .padding(25)
                }
                .background(Color("lightBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, -130)
                .padding(.bottom, 75)
                .padding(.horizontal, 30)
            }
            
            VStack {
                Spacer()
                
                AppImageButton(imageName: "mulaiButton") { //ujiPengetahuanButton
                    router.pop()
                }
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func moduleSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.shakyComicBold(size: 30))
                .bold()
                .foregroundStyle(Color("Secondary"))
            
            Text(content)
                .font(.body)
                .foregroundStyle(.black.opacity(0.75))
        }
    }
}

#Preview {
    LevelScreen()
        .environment(RouterViewModel())
}
