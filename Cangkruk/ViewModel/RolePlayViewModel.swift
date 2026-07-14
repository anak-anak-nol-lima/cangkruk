import SwiftUI

@MainActor
@Observable
class RolePlayViewModel {
    private let llm: ILLMService
    let speechToText = SpeechToTextViewModel()
    let textToSpeech = TextToSpeechViewModel()

    let scenario: RolePlayScenario
    private let sessionLength: Duration = .seconds(180)

    var messages: [ChatMessage] = []

    var isPreparing = true
    var isThinking = false
    var isSessionOver = false
    var errorMessage: String?

    private var timerTask: Task<Void, Never>?

    init(scenario: RolePlayScenario, llm: ILLMService = MLXLLMService()) {
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
                isPreparing = false   // stop the spinner — otherwise it spins forever behind the error
                errorMessage = "Gagal memuat model: \(error.localizedDescription)"
            }
        }
    }

    private func startTimer() {
        timerTask = Task {
            try? await Task.sleep(for: sessionLength)
            guard !Task.isCancelled else { return }
            endSession()
        }
    }

    func endSession() {          // NOT private — the screen's X button calls this
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
