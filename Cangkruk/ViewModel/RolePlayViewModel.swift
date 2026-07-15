import SwiftUI

@MainActor
@Observable
class RolePlayViewModel {
    private let llm: ILLMService
    let speechToText = SpeechToTextViewModel()
    let textToSpeech = TextToSpeechViewModel()

    let scenario: RolePlayScenario
    private let sessionLength: Duration = .seconds(30)

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

    // satu baris ini yang menentukan otaknya di mana:
    // APILLMService() = server (app ramping, butuh internet)
    // MLXLLMService() = on-device (offline, app bawa model 3.5GB)
    init(scenario: RolePlayScenario, llm: ILLMService = APILLMService()) {
        self.scenario = scenario
        self.llm = llm

        speechToText.onFinalTranscript = { [weak self] transcript in
            self?.handleBaristaSpeech(transcript)
        }
    }

    func startSession() {
        Task {
            do {
                let menu = """
                    Espresso 18rb, Americano 22rb, Cappuccino 28rb, Latte 30rb, \
                    V60 30rb, Cold Brew 32rb, Matcha Latte 32rb, Cokelat 28rb. \
                    Semua bisa iced/hot. Susu oat tambah 5rb.
                    """
                try await llm.startsession(systemPrompt: scenario.systemPrompt(menuContext: menu))
                isPreparing = false
                startTimer()
            } catch {
                isPreparing = false
                errorMessage = "Gagal memuat model: \(error.localizedDescription)"
            }
        }
    }

    private func startTimer() {
        timerTask = Task {
            try? await Task.sleep(for: sessionLength)
            guard !Task.isCancelled else { return }
            finishSession()
        }
    }

    // dipanggil saat timer habis: sesi berakhir NORMAL, jadi minta penilaian.
    // beda dengan endSession() yang dipanggil tombol X (keluar paksa, tanpa nilai)
    private func finishSession() {
        speechToText.stopPlaying()
        isSessionOver = true

        guard !messages.isEmpty else {
            llm.endsession()
            return
        }

        isGeneratingFeedback = true
        Task {
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

    private func handleBaristaSpeech(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isSessionOver, !isThinking, !trimmed.isEmpty else { return }

        messages.append(ChatMessage(role: .barista, text: trimmed))

        isThinking = true
        Task {
            do {
                let reply = try await llm.send(trimmed)
                guard !isSessionOver else { return }
                messages.append(ChatMessage(role: .customer, text: reply))
                textToSpeech.speak(reply)
            } catch {
                errorMessage = "Pelanggan tidak merespons: \(error.localizedDescription)"
            }
            isThinking = false
        }
    }
}
