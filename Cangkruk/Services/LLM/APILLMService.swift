//
//  APILLMService.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import Foundation

final class APILLMService: ILLMService {
    private var networkManager: NetworkManagerProtocol
    private var systemPrompt: String?
    private var history: [ChatMessage] = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    private struct FeedbackResponse: Decodable {
        let summary: String
        let feedback: String
    }

    func startsession(systemPrompt: String) async throws {
        self.systemPrompt = systemPrompt
        history = []
    }

    func send(_ baristaText: String) async throws -> String {
        guard let systemPrompt else { throw LLMError.noActiveSession }
        do {
            history.append(
                ChatMessage(
                    role: .barista,
                    text: baristaText
                )
            )
            let req = ReplyRequest(
                systemPrompt: systemPrompt,
                messages: history
            )
            let body = try JSONEncoder().encode(req)
            guard let data = try await networkManager.post(path: "/roleplay/reply", req: body) else {
                return ""
            }
            let reply = try JSONDecoder().decode(ReplyResponse.self, from: data).reply
                .trimmingCharacters(in: .whitespacesAndNewlines)
            history.append(
                ChatMessage(
                    role: .customer,
                    text: reply
                )
            )
            return reply
        } catch {
            throw error
        }
    }

    func generateFeedback(transcript: String) async throws -> String {
        do {
            let req = FeedbackRequest(transcript: transcript)
            let body = try JSONEncoder().encode(req)
            guard let data = try await networkManager.post(path: "/roleplay/feedback", req: body) else {
                return ""
            }
            let parsed = try JSONDecoder().decode(FeedbackResponse.self, from: data)
            // dikemas ulang ke format marker supaya parser di ViewModel tetap jalan
            return "SUMMARY: \(parsed.summary)\nFEEDBACK: \(parsed.feedback)"
        } catch {
            throw error
        }
    }

    func endsession() {
        systemPrompt = nil
        history = []
    }
}
