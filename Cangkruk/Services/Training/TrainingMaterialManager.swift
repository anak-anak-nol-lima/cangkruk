//
//  TrainingMaterialManager.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 19/07/26.
//

import Foundation
import SwiftData

/// Konduktor Smart Onboarding: OCR Indonesia → map-reduce AI → simpan SwiftData.
@MainActor
final class TrainingMaterialManager {
    private let modelContext: ModelContext
    private let llm: FoundationModelsLLMService

    init(
        modelContext: ModelContext,
        llm: FoundationModelsLLMService = FoundationModelsLLMService()
    ) {
        self.modelContext = modelContext
        self.llm = llm
    }

    /// Merangkum `rawText` (Bahasa Indonesia) dan menyimpan hasil Indonesia ke `file.summarizedText`.
    @discardableResult
    func summarize(
        rawText: String,
        into file: TrainingFile,
        onProgress: (@Sendable (SummarizeProgress) -> Void)? = nil
    ) async throws -> TrainingMaterialResponse {
        let indonesianMaterial = try await llm.generateTrainingMaterial(
            from: rawText,
            onProgress: onProgress
        )

        try Task.checkCancellation()

        if file.extractedText == nil {
            file.extractedText = rawText
        }
        file.summarizedText = try encode(indonesianMaterial)

        try modelContext.save()
        return indonesianMaterial
    }

    /// Membuat `TrainingFile` baru, merangkum, lalu menyimpannya ke SwiftData.
    @discardableResult
    func process(
        rawText: String,
        section: TrainingFileSection,
        fileName: String = "untitled.txt",
        onProgress: (@Sendable (SummarizeProgress) -> Void)? = nil
    ) async throws -> TrainingMaterialResponse {
        let file = TrainingFile(
            name: fileName,
            section: section,
            storedFileName: "generated-\(UUID().uuidString).txt",
            extractedText: rawText
        )
        modelContext.insert(file)
        return try await summarize(rawText: rawText, into: file, onProgress: onProgress)
    }

    private func encode(_ material: TrainingMaterialResponse) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(material)
        guard let json = String(data: data, encoding: .utf8) else {
            throw LLMError.generationFailed("Gagal encode hasil rangkuman ke JSON.")
        }
        return json
    }
}
