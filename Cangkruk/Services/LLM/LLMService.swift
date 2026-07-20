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
    case generationFailed(String)
    case cancelled

    // teks inilah yang muncul di error.localizedDescription — jauh lebih
    // berguna daripada default "LLMError error 1"
    var errorDescription: String? {
        switch self {
        case .modelNotFound: "Model tidak ditemukan di dalam app."
        case .noActiveSession: "Sesi belum dimulai."
        case .serverError(let detail): "Server bermasalah: \(detail)"
        case .generationFailed(let detail): "Gagal menghasilkan materi: \(detail)"
        case .cancelled: "Proses rangkuman dibatalkan."
        }
    }
}

/// Status progres map-reduce untuk UI loading dinamis.
enum SummarizeProgress: Equatable {
    case preparing
    case translatingToEnglish(chunk: Int, total: Int)
    case summarizing(chunk: Int, total: Int)
    case translatingToIndonesian(chunk: Int, total: Int)
    case aggregating

    var message: String {
        switch self {
        case .preparing:
            return "Menyiapkan dokumen…"
        case .translatingToEnglish(let chunk, let total):
            return total > 1
                ? "Menerjemahkan teks… (\(chunk)/\(total))"
                : "Menerjemahkan teks…"
        case .summarizing(let chunk, let total):
            return total > 1
                ? "Merangkum bagian \(chunk) dari \(total)…"
                : "Merangkum dengan AI…"
        case .translatingToIndonesian(let chunk, let total):
            return total > 1
                ? "Menerjemahkan hasil… (\(chunk)/\(total))"
                : "Menerjemahkan hasil…"
        case .aggregating:
            return "Menggabungkan hasil…"
        }
    }
}


protocol ILLMService {
    func startsession (systemPrompt: String) async throws
    func send (_ baristaText:String) async throws -> String
    func generateFeedback (transcript: String) async throws -> String
    func endsession ()
}
