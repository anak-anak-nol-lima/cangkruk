//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import SwiftData

struct LevelScreen: View {

    // MARK: - Input
    let level: Int

    // MARK: - State
    @Environment(RouterViewModel.self) private var router

    // Materi pelatihan terfilter per level (Level 1 = resep/menu, Level 2 = sop)
    @Query private var trainingFiles: [TrainingFile]

    // hasil latihan tersimpan, terbaru di atas — @Query bikin list ini
    // refresh sendiri tiap ada FeedbackResult baru masuk SwiftData
    @Query(sort: \FeedbackResult.date, order: .reverse) private var results: [FeedbackResult]
    @State private var selectedResult: FeedbackResult?

    init(level: Int) {
        self.level = level
        let sectionKey = Self.sectionKey(for: level)
        _trainingFiles = Query(
            filter: #Predicate<TrainingFile> { $0.section == sectionKey },
            sort: \TrainingFile.date,
            order: .reverse
        )
    }

    /// Level 1 → Pengetahuan Menu (`resep`); Level 2 → SOP (`sop`).
    private static func sectionKey(for level: Int) -> String {
        switch level {
        case 1: return TrainingFileSection.resep.rawValue
        case 2: return TrainingFileSection.sop.rawValue
        default: return TrainingFileSection.resep.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        router.pop()
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundStyle(Color("Primary"))
                            .padding(.bottom, 10)
                    }
                    .buttonStyle(.plain)
                    
                    Text("LEVEL \(level)")
                        .font(.shakyComicBold(size: 50))
                        .bold()
                        .foregroundStyle(Color("Secondary"))
                        .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    AppLottie(animation: "CangkrukWipe")
                        .frame(width: 350)
                        .scaleEffect(2.0)
                        .offset(x: 90, y: 50)
                        .allowsHitTesting(false)
                }
                .padding(.top, 20)
                .zIndex(1)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 24) {
                            if trainingFiles.isEmpty {
                                moduleSection(
                                    title: defaultModuleTitle,
                                    content: "Belum ada materi untuk level ini. Minta manajer mengunggah file terlebih dahulu."
                                )
                            } else {
                                ForEach(trainingFiles) { file in
                                    moduleSection(
                                        title: moduleTitle(for: file),
                                        content: moduleContent(for: file)
                                    )
                                }
                            }
                        }
                        .padding(25)
                        .background(Color("lightBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        hasilSection
                        
                        Spacer(minLength: 100) // spacer agar tidak tertutup button mulai
                    }.padding(.top, 20)
                }
            }.padding(.horizontal, 30)
            
            VStack {
                Spacer()
                
                AppButton(label: "Mulai") {
                    router.push(.roleplay)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(item: $selectedResult) { result in
            HasilScreen(summary: result.summary, feedback: result.feedback)
        }
    }

    private var defaultModuleTitle: String {
        level == 2 ? "SOP" : "PRODUK MENU"
    }

    private func moduleTitle(for file: TrainingFile) -> String {
        if let material = decodedMaterial(from: file) {
            return material.title
        }
        return file.name
    }

    /// Hasil AI siap pakai; jika belum matang, placeholder (atau fallback OCR).
    private func moduleContent(for file: TrainingFile) -> String {
        if let material = decodedMaterial(from: file) {
            return material.rawMarkdown
        }

        if let summarized = file.summarizedText?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !summarized.isEmpty {
            return summarized
        }

        if let extracted = file.extractedText?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !extracted.isEmpty {
            return "Sedang diproses oleh sistem…"
        }

        return "Materi belum tersedia."
    }

    private func decodedMaterial(from file: TrainingFile) -> TrainingMaterialResponse? {
        guard let summarized = file.summarizedText?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !summarized.isEmpty,
              let data = summarized.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(TrainingMaterialResponse.self, from: data)
    }

    // format tanggal persis mockup: 10-10-2026
    private static let hasilDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    @ViewBuilder
    private var hasilSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HASIL")
                .font(.shakyComicBold(size: 30))
                .bold()
                .foregroundStyle(Color("Secondary"))
            
            if results.isEmpty {
                HStack {
                    Spacer()
                    Text("Kamu belum melakukan tes")
                        .font(.body)
                        .foregroundStyle(.black.opacity(0.5))
                        .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                        Button {
                            selectedResult = result
                        } label: {
                            HStack {
                                Text("Summary \(results.count - index)")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Text(Self.hasilDateFormatter.string(from: result.date))
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.black.opacity(0.75))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Background"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("Secondary").opacity(0.25), lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(Color("lightBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
                .lineSpacing(4)
        }
    }
}

#Preview {
    LevelScreen(level: 1)
        .environment(RouterViewModel())
        .modelContainer(for: [FeedbackResult.self, TrainingFile.self], inMemory: true)
}
