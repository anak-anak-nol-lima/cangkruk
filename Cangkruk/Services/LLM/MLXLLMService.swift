//
//  Untitled.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//

import Foundation
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

    func endsession() {
        session = nil
    }
}
