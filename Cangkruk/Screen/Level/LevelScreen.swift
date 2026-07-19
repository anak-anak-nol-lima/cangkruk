//
//  LevelScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import SwiftData

struct LevelScreen: View {
    let levelNumber: Int
    
    // MARK: - State
    @State private var isRolePlaying: Bool = false
    @Environment(RouterViewModel.self) private var router
    
    // hasil latihan tersimpan, terbaru di atas — @Query bikin list ini
    // refresh sendiri tiap ada FeedbackResult baru masuk SwiftData
    @Query(sort: \FeedbackResult.date, order: .reverse) private var results: [FeedbackResult]
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
                    
                    Text("LEVEL \(levelNumber)")
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
                            
                            if let levelMaterials {
                                ForEach(levelMaterials) { material in
                                    let cleaned = material.body.replacingOccurrences(of: "\\n", with: "\n")
                                    moduleSection(
                                        title: material.title,
                                        content: cleaned
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
                    router.push(.roleplay(levelNumber))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(item: $selectedResult) { result in
            ResultScreen(summary: result.summary, feedback: result.feedback)
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
            
            if let attributedString = try? AttributedString(
                markdown: content,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            ) {
                // rendering the markdown
                Text(attributedString)
                    .font(.body)
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

#Preview {
    LevelScreen(levelNumber: 1)
        .environment(RouterViewModel())
        .modelContainer(for: FeedbackResult.self, inMemory: true)
    
}
