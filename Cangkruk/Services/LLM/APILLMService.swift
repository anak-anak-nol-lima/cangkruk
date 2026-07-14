//
//  APILLMService.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import Foundation

// versi "otak di server": percakapan dikirim ke cangkruk.gagas.tech,
// Gemini yang mikir di sana. Server-nya stateless — riwayat chat
// disimpan di sini dan dikirim utuh tiap giliran (makanya tanpa DB)
final class APILLMService: ILLMService {
    private let baseURL = URL(string: "https://cangkruk.gagas.tech")!

    private var systemPrompt: String?
    private var history: [ChatMessage] = []

    private struct ReplyResponse: Decodable { let reply: String }
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

        history.append(ChatMessage(role: .barista, text: baristaText))
        let body: [String: Any] = [
            "system_prompt": systemPrompt,
            "messages": history.map {
                ["role": $0.role == .barista ? "barista" : "customer", "text": $0.text]
            },
        ]

        let data = try await post(path: "/roleplay/reply", body: body)
        let reply = try JSONDecoder().decode(ReplyResponse.self, from: data).reply
            .trimmingCharacters(in: .whitespacesAndNewlines)
        history.append(ChatMessage(role: .customer, text: reply))
        return reply
    }

    func generateFeedback(transcript: String) async throws -> String {
        let data = try await post(path: "/roleplay/feedback", body: ["transcript": transcript])
        let parsed = try JSONDecoder().decode(FeedbackResponse.self, from: data)
        // dikemas ulang ke format marker supaya parser di ViewModel tetap jalan
        return "SUMMARY: \(parsed.summary)\nFEEDBACK: \(parsed.feedback)"
    }

    func endsession() {
        systemPrompt = nil
        history = []
    }

    private func post(path: String, body: [String: Any]) async throws -> Data {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LLMError.serverError("respons bukan HTTP")
        }
        guard http.statusCode == 200 else {
            let detail = String(data: data, encoding: .utf8) ?? ""
            throw LLMError.serverError("HTTP \(http.statusCode) \(detail.prefix(120))")
        }
        return data
    }
}
