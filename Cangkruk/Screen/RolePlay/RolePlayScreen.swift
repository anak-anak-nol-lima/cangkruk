//
//  RolePlayScreen.swift
//  Cangkruk
//

import SwiftUI
import SwiftData

struct RolePlayScreen: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext


    @State private var viewModel: RolePlayViewModel

    @State private var isError: Bool = false
    @State private var errorText: String = ""
    @State private var showHasil = false
    @State private var hasSavedResult = false

    init(isPresented: Binding<Bool>, scenario: RolePlayScenario = RolePlayScenario.all[0]) {
        self._isPresented = isPresented
        self._viewModel = State(initialValue: RolePlayViewModel(scenario: scenario))
    }

    private func showError(_ message: String?) {
        guard let message, !message.isEmpty else { return }
        errorText = message
        isError = true
    }

    var body: some View {
        ZStack {
            VStack {
                // top bar
                HStack {
                    Text(viewModel.scenario.name)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "xmark")
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .onTapGesture {
                            viewModel.endSession()   
                            isPresented = false
                        }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)

              
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .onTapGesture {
                                    viewModel.textToSpeech.speak(message.text)
                                }
                        }
                        if viewModel.isThinking {
                            Text("Pelanggan sedang berpikir...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

            
                if viewModel.speechToText.isPlaying {
                    Text("Sedang mendengarkan...")
                        .font(.caption).bold().foregroundStyle(.red)
                    Text(viewModel.speechToText.currentText)
                        .font(.caption).bold()
                }

                if viewModel.isPreparing {
                    ProgressView("Menyiapkan pelanggan... (pertama kali bisa lama)")
                        .padding(.bottom, 24)
                } else if !viewModel.isSessionOver {
                    RecordButton() {
                        Task { await viewModel.speechToText.processMic() }
                    }
                    .disabled(viewModel.isThinking)
                    .opacity(viewModel.isThinking ? 0.4 : 1)
                } else {
                    VStack(spacing: 8) {
                        Text("Sesi selesai!").font(.headline)
                        if viewModel.isGeneratingFeedback {
                            ProgressView("Pelanggan sedang menilai kamu...")
                        } else {
                            AppButton(label: "Lihat Hasil") {
                                showHasil = true
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear { viewModel.startSession() }   // <-- hires the conductor
        .sheet(isPresented: $showHasil) {
            HasilScreen(
                summary: viewModel.feedbackSummary ?? "Belum ada penilaian untuk sesi ini.",
                feedback: viewModel.feedbackText ?? ""
            )
        }
        
        .onChange(of: viewModel.isGeneratingFeedback) { _, generating in
            guard !generating, !hasSavedResult,
                  let summary = viewModel.feedbackSummary else { return }
            hasSavedResult = true
            modelContext.insert(FeedbackResult(
                levelNumber: viewModel.scenario.difficulty,
                scenarioName: viewModel.scenario.name,
                summary: summary,
                feedback: viewModel.feedbackText ?? ""
            ))
        }
        .overlay(alignment: .bottom) {
            if isError {
                AppSnackbar(errorMessage: errorText, type: .error, isPresented: $isError)
            }
        }
        .onChange(of: viewModel.errorMessage) { _, new in showError(new) }
        .onChange(of: viewModel.speechToText.errorMessage) { _, new in showError(new) }
        .onChange(of: viewModel.textToSpeech.errorMessage) { _, new in showError(new) }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .barista { Spacer(minLength: 48) }

            Text(message.text)
                .font(.body)
                .foregroundStyle(message.role == .barista ? .white : .primary)
                .padding(12)
                .background(message.role == .barista ? Color.black.opacity(0.7) : Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if message.role == .customer { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    RolePlayScreen(isPresented: .constant(true))
}
