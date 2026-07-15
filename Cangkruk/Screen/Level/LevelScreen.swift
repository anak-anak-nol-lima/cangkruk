//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import SwiftData

struct LevelScreen: View {

    // MARK: - State
    @State private var isRolePlaying: Bool = false
    @Environment(RouterViewModel.self) private var router

    // hasil latihan tersimpan, terbaru di atas — @Query bikin list ini
    // refresh sendiri tiap ada FeedbackResult baru masuk SwiftData
    @Query(sort: \FeedbackResult.date, order: .reverse) private var results: [FeedbackResult]
    @State private var selectedResult: FeedbackResult?
    
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
                        hasilSection
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
                
                AppButton(imageName: "mulaiButton") {
                    router.push(.roleplay)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(item: $selectedResult) { result in
            HasilScreen(summary: result.summary, feedback: result.feedback)
        }
    }

    // format tanggal persis mockup: 10-10-2026
    private static let hasilDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    @ViewBuilder
    private var hasilSection: some View {
        if !results.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("HASIL")
                    .font(.shakyComicBold(size: 30))
                    .bold()
                    .foregroundStyle(Color("Secondary"))

                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    Button {
                        selectedResult = result
                    } label: {
                        HStack {
                            Text("Summary \(results.count - index)")
                            Spacer()
                            Text(Self.hasilDateFormatter.string(from: result.date))
                        }
                        .font(.body)
                        .foregroundStyle(.black.opacity(0.75))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("lightBackground"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Secondary").opacity(0.45), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
        .modelContainer(for: FeedbackResult.self, inMemory: true)
}
