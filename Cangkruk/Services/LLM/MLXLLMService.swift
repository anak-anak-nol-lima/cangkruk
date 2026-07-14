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
    // heavy shared resource again: load once, reuse forever
   
    
    private static var loadedModel: ModelContext?


    private var session: ChatSession?

    // the model ships INSIDE the app bundle (blue folder reference in Xcode)
    // so first launch needs zero network — matches the semi-offline pitch.
    // folder = Models/gemma-4-e2b-it-4bit (repo root, gitignored)
    private let modelFolderName = "gemma-4-e2b-it-4bit"

    func startsession(systemPrompt: String) async throws {
        if Self.loadedModel == nil {
            // Bundle.main = the installed .app; url(forResource:) finds our
            // model folder inside it. nil here means the folder reference
            // wasn't added to the target — a build setup error, not a user error.
            guard let modelDir = Bundle.main.url(forResource: modelFolderName, withExtension: nil) else {
                throw LLMError.modelNotFound
            }
            // reads the weights straight off disk into the GPU. No network.
            // 3.x API: we hand it a tokenizer loader instead of it owning one.
            Self.loadedModel = try await loadModel(
                from: modelDir,
                using: #huggingFaceTokenizerLoader()
            )
        }
        guard let model = Self.loadedModel else { throw LLMError.modelNotFound }
        // instructions = the official system-prompt slot; the chat template
        // gives it the "system" role so the model treats it as rules, not chat
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
