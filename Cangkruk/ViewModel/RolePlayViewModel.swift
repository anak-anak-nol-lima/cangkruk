//
//  RouterViewModel.swift
//  Cangkruk
//
//  Created by Joren on 15/07/26.
//


import SwiftUI

@Observable
class RolePlayViewModel {
    // MARK: - Constant
    private let llm: ILLMService
    let speechToText = SpeechToTextViewModel()
    let textToSpeech = TextToSpeechViewModel(textToSpeech: GeminiTextToSpeech())
    let scenario: RolePlayScenario
    private let sessionLength: Duration = .seconds(60 * 5)

    
    // MARK: - Variable
    private var sessionSeconds: Int { Int(sessionLength.components.seconds) }
    var remainingSeconds: Int = 0
    var messages: [ChatMessage] = []
    var isPreparing = true
    var isThinking = false
    var isSessionOver = false
    var isGeneratingFeedback = false
    var feedbackSummary: String?
    var feedbackText: String?
    var sessionTranscript: String?
    var errorMessage: String?
    private var timerTask: Task<Void, Never>?
    
    
    init(
        scenario: RolePlayScenario,
        llm: ILLMService = APILLMService(
            networkManager: NetworkManager(host: "https://cangkruk.gagas.tech")
        )) {
            // when first initialize the viewmodel
            // it will init the Network for rest call to the API
            // it initialize the scenario from the caller too, for the randomize case
            self.scenario = scenario
            self.llm = llm
            
            // onFinalTranscript will
            speechToText.onFinalTranscript = { [weak self] transcript in
                await self?.handleBaristaSpeech(transcript)
            }
        }
    
    func startSession() async {
        do {
            let menu = """
                Espresso 18rb, Americano 22rb, Cappuccino 28rb, Latte 30rb, \
                V60 30rb, Cold Brew 32rb, Matcha Latte 32rb, Cokelat 28rb. \
                Semua bisa iced/hot. Susu oat tambah 5rb.
                """
            try await llm.startsession(systemPrompt: scenario.systemPrompt(menuContext: menu))
            isPreparing = false
            remainingSeconds = sessionSeconds
        } catch {
            isPreparing = false
            errorMessage = "Gagal memuat model: \(error.localizedDescription)"
        }
    }
    
    func startTimer() {
        timerTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1
            }
            await finishSession()
        }
    }
    
    // dipanggil saat timer habis: sesi berakhir NORMAL, jadi minta penilaian.
    // beda dengan endSession() yang dipanggil tombol X (keluar paksa, tanpa nilai)
    func finishSession() async {
        timerTask?.cancel()
        speechToText.stopPlaying()
        isSessionOver = true
        
        //        guard !messages.isEmpty else {
        //            llm.endsession()
        //            return
        //        }
        
        isGeneratingFeedback = true
        do {
            let transcript = messages
                .map { "\($0.role == .barista ? "Barista" : "Pelanggan"): \($0.text)" }
                .joined(separator: "\n")
            sessionTranscript = transcript
            let raw = try await llm.generateFeedback(transcript: transcript)
            (feedbackSummary, feedbackText) = Self.parseFeedback(raw)
        } catch {
            errorMessage = "Gagal membuat penilaian: \(error.localizedDescription)"
        }
        isGeneratingFeedback = false
        llm.endsession()
    }
    
    // model kecil kadang tidak patuh format — parser ini memaafkan:
    // kalau marker FEEDBACK: tidak ketemu, seluruh teks jadi summary
    static func parseFeedback(_ raw: String) -> (String, String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let marker = text.range(of: "FEEDBACK:", options: .caseInsensitive) else {
            return (text, "")
        }
        var summary = String(text[..<marker.lowerBound])
        if let s = summary.range(of: "SUMMARY:", options: .caseInsensitive) {
            summary = String(summary[s.upperBound...])
        }
        let feedback = String(text[marker.upperBound...])
        return (summary.trimmingCharacters(in: .whitespacesAndNewlines),
                feedback.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func endSession() {
        timerTask?.cancel()
        speechToText.stopPlaying()
        llm.endsession()
        isSessionOver = true
    }
    
    func handleBaristaSpeech(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isSessionOver, !isThinking, !trimmed.isEmpty else { return }
        
        messages.append(ChatMessage(role: .barista, text: trimmed))
        
        isThinking = true
        do {
            let reply = try await llm.send(trimmed)
            guard !isSessionOver else { return }
            messages.append(ChatMessage(role: .customer, text: reply))
            await textToSpeech.speak(reply)
        } catch {
            errorMessage = "Pelanggan tidak merespons: \(error.localizedDescription)"
        }
        isThinking = false
    }
}
