//
//  LLMService.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//


import Foundation

enum LLMError: LocalizedError {
    case modelNotFound
    case noActiveSession
    case serverError(String)

    // teks inilah yang muncul di error.localizedDescription — jauh lebih
    // berguna daripada default "LLMError error 1"
    var errorDescription: String? {
        switch self {
        case .modelNotFound: "Model tidak ditemukan di dalam app."
        case .noActiveSession: "Sesi belum dimulai."
        case .serverError(let detail): "Server bermasalah: \(detail)"
        }
    }
}


protocol ILLMService {
    func startsession (systemPrompt: String) async throws
    func send (_ baristaText:String) async throws -> String
    func generateFeedback (transcript: String) async throws -> String
    func endsession ()
}
