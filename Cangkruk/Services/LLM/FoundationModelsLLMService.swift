//
//  FoundationModelsLLMService.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 19/07/26.
//

import Foundation
import FoundationModels
import NaturalLanguage

// materi di chunck terlebih dahulu agar tidak memberatkan proses translation & generating context
// Map-reduce: chunk → (optional ID→EN) → generate → EN→ID → aggregate.
final class FoundationModelsLLMService {
    private let translator: OnDeviceTranslationService
    private let maxChunkLength: Int

    init(
        translator: OnDeviceTranslationService = OnDeviceTranslationService(),
        maxChunkLength: Int = TextChunker.defaultMaxLength
    ) {
        self.translator = translator
        // panjang teks max 800
        self.maxChunkLength = min(
            max(maxChunkLength, 800),
            TextChunker.absoluteMaxLength
        )
    }

    // Full pipeline for document OCR text, safe for long SOP/Menu documents
    func generateTrainingMaterial(
        from indonesianRawText: String,
        onProgress: (@Sendable (SummarizeProgress) -> Void)? = nil
    ) async throws -> TrainingMaterialResponse {
        onProgress?(.preparing)

        let chunks = TextChunker.split(indonesianRawText, maxLength: maxChunkLength)
        guard !chunks.isEmpty else {
            throw LLMError.generationFailed("Teks dokumen kosong, tidak bisa dirangkum.")
        }

        // Belt-and-suspenders: tolak chunk yang kebobolan (seharusnya tidak terjadi).
        precondition(
            chunks.allSatisfy { $0.count <= TextChunker.absoluteMaxLength },
            "TextChunker produced an oversized chunk"
        )

        var partialResults: [TrainingMaterialResponse] = []
        partialResults.reserveCapacity(chunks.count)

        let total = chunks.count

        for (index, chunk) in chunks.enumerated() {
            try Self.throwIfCancelled()

            let part = index + 1
            let englishChunk: String
            if Self.isAlreadyEnglish(chunk) {
                englishChunk = chunk
            } else {
                onProgress?(.translatingToEnglish(chunk: part, total: total))
                englishChunk = try await translator.translateIndonesianToEnglish(chunk)
            }

            // jika hasil translate kepanjangan: di chunck ulang sebelum masuk model
            let englishPieces = TextChunker.split(englishChunk, maxLength: maxChunkLength)

            for (pieceIndex, englishPiece) in englishPieces.enumerated() {
                try Self.throwIfCancelled()
                onProgress?(.summarizing(chunk: part, total: total))

                let englishMaterial = try await generateEnglishMaterialInFreshSession(
                    from: englishPiece,
                    chunkIndex: index,
                    pieceIndex: pieceIndex,
                    pieceCount: englishPieces.count,
                    totalChunks: total
                )

                try Self.throwIfCancelled()
                onProgress?(.translatingToIndonesian(chunk: part, total: total))
                let indonesianMaterial = try await translator.translateMaterialToIndonesian(englishMaterial)
                partialResults.append(indonesianMaterial)
            }
        }

        try Self.throwIfCancelled()
        onProgress?(.aggregating)
        return Self.aggregate(partialResults)
    }

    // MARK: - Language Detection (NaturalLanguage)
    private static func dominantLanguage(of text: String) -> NLLanguage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)
        return recognizer.dominantLanguage
    }
    
    private static func isAlreadyEnglish(_ text: String) -> Bool {
        dominantLanguage(of: text) == .english
    }

    private static func throwIfCancelled() throws {
        if Task.isCancelled {
            throw LLMError.cancelled
        }
    }

    private func generateEnglishMaterialInFreshSession(
        from englishRawText: String,
        chunkIndex: Int,
        pieceIndex: Int,
        pieceCount: Int,
        totalChunks: Int
    ) async throws -> TrainingMaterialResponse {
        try Self.throwIfCancelled()

        let cappedText: String
        if englishRawText.count <= TextChunker.absoluteMaxLength {
            cappedText = englishRawText
        } else {
            cappedText = String(englishRawText.prefix(TextChunker.absoluteMaxLength))
        }

        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw LLMError.generationFailed(
                "Apple Intelligence tidak tersedia: \(String(describing: reason))"
            )
        }

        var prompt = PromptEngine.createPrompt(for: cappedText)
        if totalChunks > 1 || pieceCount > 1 {
            let pieceNote = pieceCount > 1 ? " (sub-part \(pieceIndex + 1)/\(pieceCount))" : ""
            prompt += """


            NOTE: This is part \(chunkIndex + 1) of \(totalChunks)\(pieceNote) of a longer document.
            Summarize only the content in this part. Do not invent missing sections.
            """
        }

        do {
            // session hanya berjalan 1x, ganti session = ganti history
            let content: TrainingMaterialResponse = try await {
                let session = LanguageModelSession(model: model)
                let response = try await session.respond(
                    to: prompt,
                    generating: TrainingMaterialResponse.self
                )
                return response.content
            }()

            try Self.throwIfCancelled()
            return content
        } catch is CancellationError {
            throw LLMError.cancelled
        } catch let error as LLMError {
            throw error
        } catch {
            if Task.isCancelled { throw LLMError.cancelled }
            throw LLMError.generationFailed(error.localizedDescription)
        }
    }

    private static func aggregate(
        _ materials: [TrainingMaterialResponse]
    ) -> TrainingMaterialResponse {
        guard let first = materials.first else {
            return TrainingMaterialResponse(title: "", sections: [], rawMarkdown: "")
        }

        if materials.count == 1 {
            return first
        }

        var headingOrder: [String] = []
        var bulletsByHeading: [String: [String]] = [:]

        for material in materials {
            for section in material.sections {
                let key = section.heading.trimmingCharacters(in: .whitespacesAndNewlines)
                if bulletsByHeading[key] == nil {
                    headingOrder.append(key)
                    bulletsByHeading[key] = []
                }
                bulletsByHeading[key, default: []].append(contentsOf: section.bulletPoints)
            }
        }

        let sections = headingOrder.map { heading in
            TrainingSection(
                heading: heading,
                bulletPoints: bulletsByHeading[heading] ?? []
            )
        }

        return TrainingMaterialResponse(
            title: first.title,
            sections: sections,
            rawMarkdown: buildMarkdown(from: sections)
        )
    }

    private static func buildMarkdown(from sections: [TrainingSection]) -> String {
        sections.map { section in
            let bullets = section.bulletPoints.map { "- \($0)" }.joined(separator: "\n")
            return "## \(section.heading)\n\(bullets)"
        }
        .joined(separator: "\n\n")
    }
}
