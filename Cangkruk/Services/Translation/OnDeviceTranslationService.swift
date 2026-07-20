//
//  OnDeviceTranslationService.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 19/07/26.
//

import Foundation
import Translation

/// On-device translation bridge (Apple Translation) between Indonesian and English.
/// Used so Foundation Models can process English while the app stores Indonesian.
final class OnDeviceTranslationService {
    private let indonesian = Locale.Language(identifier: "id")
    private let english = Locale.Language(identifier: "en")
    private let maxChunkLength = 2_400

    func translateIndonesianToEnglish(_ text: String) async throws -> String {
        try await translate(text, from: indonesian, to: english)
    }

    func translateEnglishToIndonesian(_ text: String) async throws -> String {
        try await translate(text, from: english, to: indonesian)
    }

    /// Translates structured AI output field-by-field, then rebuilds Indonesian markdown.
    func translateMaterialToIndonesian(
        _ material: TrainingMaterialResponse
    ) async throws -> TrainingMaterialResponse {
        var requests: [TranslationSession.Request] = [
            .init(sourceText: material.title, clientIdentifier: "title")
        ]

        for (sectionIndex, section) in material.sections.enumerated() {
            requests.append(
                .init(
                    sourceText: section.heading,
                    clientIdentifier: "s\(sectionIndex).heading"
                )
            )
            for (bulletIndex, bullet) in section.bulletPoints.enumerated() {
                requests.append(
                    .init(
                        sourceText: bullet,
                        clientIdentifier: "s\(sectionIndex).b\(bulletIndex)"
                    )
                )
            }
        }

        let session = try await makeSession(from: english, to: indonesian)
        let responses = try await session.translations(from: requests)
        let translated = Dictionary(
            uniqueKeysWithValues: responses.compactMap { response -> (String, String)? in
                guard let id = response.clientIdentifier else { return nil }
                return (id, response.targetText)
            }
        )

        let title = translated["title"] ?? material.title
        let sections: [TrainingSection] = material.sections.enumerated().map { sectionIndex, section in
            let heading = translated["s\(sectionIndex).heading"] ?? section.heading
            let bullets = section.bulletPoints.enumerated().map { bulletIndex, bullet in
                translated["s\(sectionIndex).b\(bulletIndex)"] ?? bullet
            }
            return TrainingSection(heading: heading, bulletPoints: bullets)
        }

        return TrainingMaterialResponse(
            title: title,
            sections: sections,
            rawMarkdown: Self.buildMarkdown(from: sections)
        )
    }

    private func translate(
        _ text: String,
        from source: Locale.Language,
        to target: Locale.Language
    ) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        let session = try await makeSession(from: source, to: target)
        let chunks = chunk(trimmed)

        if chunks.count == 1 {
            return try await session.translate(chunks[0]).targetText
        }

        var translatedChunks: [String] = []
        translatedChunks.reserveCapacity(chunks.count)
        for chunk in chunks {
            let response = try await session.translate(chunk)
            translatedChunks.append(response.targetText)
        }
        return translatedChunks.joined(separator: "\n\n")
    }

    private func makeSession(
        from source: Locale.Language,
        to target: Locale.Language
    ) async throws -> TranslationSession {
        let availability = LanguageAvailability()
        let status = await availability.status(from: source, to: target)

        switch status {
        case .installed:
            break
        case .supported:
            throw LLMError.generationFailed(
                "Paket bahasa terjemahan belum terpasang. Unduh bahasa Indonesia dan English di app Translate, lalu coba lagi."
            )
        case .unsupported:
            throw LLMError.generationFailed(
                "Pasangan bahasa Indonesia ↔ English tidak didukung di perangkat ini."
            )
        @unknown default:
            throw LLMError.generationFailed("Status terjemahan tidak dikenali.")
        }

        return TranslationSession(installedSource: source, target: target)
    }

    private func chunk(_ text: String) -> [String] {
        guard text.count > maxChunkLength else { return [text] }

        let paragraphs = text.components(separatedBy: "\n\n")
        var chunks: [String] = []
        var current = ""

        for paragraph in paragraphs {
            let candidate = current.isEmpty ? paragraph : current + "\n\n" + paragraph
            if candidate.count > maxChunkLength, !current.isEmpty {
                chunks.append(current)
                current = paragraph
            } else {
                current = candidate
            }
        }

        if !current.isEmpty {
            chunks.append(current)
        }

        // Hard-split any leftover oversized paragraph.
        return chunks.flatMap { piece -> [String] in
            guard piece.count > maxChunkLength else { return [piece] }
            var parts: [String] = []
            var start = piece.startIndex
            while start < piece.endIndex {
                let end = piece.index(start, offsetBy: maxChunkLength, limitedBy: piece.endIndex) ?? piece.endIndex
                parts.append(String(piece[start..<end]))
                start = end
            }
            return parts
        }
    }

    private static func buildMarkdown(from sections: [TrainingSection]) -> String {
        sections.map { section in
            let bullets = section.bulletPoints.map { "- \($0)" }.joined(separator: "\n")
            return "## \(section.heading)\n\(bullets)"
        }
        .joined(separator: "\n\n")
    }
}
