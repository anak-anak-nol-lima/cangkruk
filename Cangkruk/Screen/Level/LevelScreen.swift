//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import SwiftData


struct LevelScreen: View {
    let levelNumber:Int

    // MARK: - State
    @State private var isRolePlaying: Bool = false
    @Environment(RouterViewModel.self) private var router
    
    // hasil latihan tersimpan, terbaru di atas — @Query bikin list ini
    // refresh sendiri tiap ada FeedbackResult baru masuk SwiftData
    @Query(sort: \FeedbackResult.date, order: .reverse) private var results: [FeedbackResult]
    private var levelResults: [FeedbackResult] {
        Array(results.filter { $0.levelNumber == levelNumber }.prefix(5))
    }
    @State private var selectedResult: FeedbackResult?
    
    @Query
    private var materials: [LevelMaterial]
    private var levelMaterials: [LevelMaterial]? {
        materials.filter { material in
            material.level == levelNumber
        }
    }
    
        var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        router.pop()
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundStyle(Color("Secondary"))
                            .padding(.bottom, 10)
                    }
                    .buttonStyle(.plain)
                    
                    Text("LEVEL \(levelNumber)")
                        .font(.shakyComicBold(size: 50))
                        .bold()
                        .foregroundStyle(Color("Primary"))
                        .padding(.horizontal, 10)
                    
                    Spacer()
                }.padding(.top, 20)
                
                VStack(spacing: 20){
                    ScrollView(showsIndicators: false) {
                        
                        if let levelMaterials {
                            ForEach(levelMaterials) { material in
                                let cleaned = material.body.replacingOccurrences(of: "\\n", with: "\n")
                                moduleSection(
                                    title: material.title,
                                    content: cleaned
                                ).padding(.top, 10)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color("lightBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    hasilSection
                }
                .padding(.bottom, 100)
                .overlay(alignment: .topTrailing) {
                    AppLottie(animation: "CangkrukWipe")
                        .frame(width: 90)
                        .scaleEffect(2.0)
                        .offset(x: -40, y: -250)
                        .allowsHitTesting(false)
                }
            }
            .screenPadding()
            
            VStack {
                Spacer()
                
                AppButton(label: "Mulai Sesi Latihan") {
                    router.push(.roleplay(levelNumber))
                }
                .screenPadding()
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(item: $selectedResult) { result in
            ResultScreen(isLevelScreen: true, summary: result.summary, feedback: result.feedback, duration: result.duration)
        }
    }
        
    @ViewBuilder
    private var hasilSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RIWAYAT LATIHAN")
                .font(.shakyComicBold(size: 30))
                .bold()
                .foregroundStyle(Color("Secondary"))
            
            if levelResults.isEmpty {
                HStack {
                    Spacer()
                    Text("Kamu belum melakukan tes")
                        .font(.body)
                        .foregroundStyle(.black.opacity(0.5))
                        .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(Array(levelResults.enumerated()), id: \.element.id) { index, result in
                            Button {
                                selectedResult = result
                            } label: {
                                HStack {
                                    Text("Summary \(levelResults.count - index)")
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    Text(ManagerView.dateFormatter.string(from: result.date))
                                        .font(.subheadline)
                                }
                                .foregroundStyle(Color("Secondary"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color("Background"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color("Secondary"), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 80)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
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
            
            if let attributedString = try? AttributedString(
                markdown: content,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            ) {
                // rendering the markdown
                Text(attributedString)
                    .font(.body)
                    .font(.system(size: 15))
                    .foregroundStyle(.black.opacity(0.75))
                    .lineSpacing(4)
            } else {
                // fallback render content
                Text(content)
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.75))
                    .lineSpacing(4)
                
            }
        }
    }
}
@Observable class isinLevelScreen { var isinLevelScreen:Bool = true }

#Preview {
    LevelScreen(levelNumber: 1)
        .environment(RouterViewModel())
        .modelContainer(for: FeedbackResult.self, inMemory: true)
    
}
