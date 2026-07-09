//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

struct LevelScreen: View {
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Produk-produk dari cafe")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 12)
                
                Text("""
                Langkah pertama sebagai barista adalah mengenal produk yang dijual. Secara umum, menu dibagi menjadi beberapa kategori:
                
                Kopi berbasis espresso Espresso, Americano, Cappuccino, Latte, dan variasinya. Semua berawal dari espresso sebagai basis rasa; yang membedakan adalah takaran air dan susunya.
                
                Manual brew kopi seduh manual seperti V60, Tubruk, dan Cold Brew. Fokusnya menonjolkan karakter dan notes dari biji kopi.
                
                Minuman non-kopi cokelat, matcha, dan teh, untuk pelanggan yang tidak minum kopi.
                
                Yang perlu kamu kuasai di tahap ini: nama produk, bahan utamanya, dan bedanya minuman milk-based vs non-milk.
                """)
                .font(.caption)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                AppButton(label: "Uji Pengetahuan Anda") {
                    
                }
            }
            .padding()
        }
        .navigationTitle("Capaian 1 - Produk")
        .padding()
    }
}

#Preview {
    LevelScreen()
}
