//
//  Untitled.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//

import Foundation
import MLX
import MLXLMCommon
import MLXLLM
import MLXVLM
import MLXHuggingFace
import Tokenizers

final class MLXLLMService: ILLMService {
   
    
    private static var loadedModel: ModelContext?


    private var session: ChatSession?

   
    private let modelFolderName = "gemma-4-e2b-it-4bit"

    func startsession(systemPrompt: String) async throws {
        
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

        if Self.loadedModel == nil {
            
            guard let modelDir = Bundle.main.url(forResource: modelFolderName, withExtension: nil) else {
                throw LLMError.modelNotFound
            }
        
            Self.loadedModel = try await loadModel(
                from: modelDir,
                using: #huggingFaceTokenizerLoader()
            )
        }
        guard let model = Self.loadedModel else { throw LLMError.modelNotFound }
        session = ChatSession(model, instructions: systemPrompt)
    }

    func send(_ baristaText: String) async throws -> String {
        guard let session else { throw LLMError.noActiveSession }
        let reply = try await session.respond(to: baristaText)
        return reply.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateFeedback(transcript: String) async throws -> String {
        guard let model = Self.loadedModel else { throw LLMError.modelNotFound }
        
        let evaluator = ChatSession(model, instructions: """
            Kamu adalah senior barista yang menilai latihan komunikasi barista junior. \
            Nilai berdasarkan: sapaan, konfirmasi pesanan, pengetahuan menu, dan penutup interaksi. \
            Jawab dalam bahasa Indonesia, panggil barista dengan "kamu", dan pakai format PERSIS seperti ini:
            SUMMARY: <2-3 kalimat penilaian keseluruhan>
            FEEDBACK: <2-3 kalimat saran konkret beserta contoh kalimat yang bisa langsung dipakai>
            """)

        let reply = try await evaluator.respond(
            to: "Berikut transkrip latihannya:\n\n\(transcript)\n\nBerikan penilaianmu sesuai format.")
        return reply.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func endsession() {
        session = nil
    }
}
