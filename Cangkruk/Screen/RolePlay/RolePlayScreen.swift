//
//  RolePlayScreen.swift
//  Cangkruk
//

import SwiftUI
import SwiftData


struct RolePlayScreen: View{
    
    @Binding var isLevelScreen: Bool
   
    // MARK: - Binding
    @Binding var isPresented: Bool
    

    
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext


    // MARK: - State
    @State private var viewModel: RolePlayViewModel
    @State private var showQuitAlert = false
    @State private var isError: Bool = false
    @State private var errorText: String = ""
    @State private var showHasil = false
    @State private var hasSavedResult = false
    @State private var showLoading = false

    init(
        isPresented: Binding<Bool>,
        scenario: RolePlayScenario = RolePlayScenario.all[0]
    ) {
        self._isPresented = isPresented
        self._viewModel = State(initialValue: RolePlayViewModel(scenario: scenario))
        self._isLevelScreen = .constant(false)
    }

    private func showError(_ message: String?) {
        guard let message, !message.isEmpty else { return }
        errorText = message
        isError = true
    }
    
    

    var body: some View {
      
        ZStack {
            Color("Background").ignoresSafeArea(.all)
            VStack {
                ZStack {
                    
                    Text(String(format: "%02d:%02d",
                                viewModel.remainingSeconds / 60,
                                viewModel.remainingSeconds % 60))
                    .font(.system(size:15))
                        .foregroundStyle(Color("Secondary"))

                    HStack {
                        Text("LEVEL \(viewModel.scenario.difficulty)")
                            .font(.shakyComicBold(size: 43))
                            .foregroundStyle(Color("Primary"))
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .foregroundStyle(Color("Secondary"))
                            .padding(.bottom, 10)
                            .onTapGesture { showQuitAlert = true }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)

              
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .onTapGesture {
                                    Task {
                                        await viewModel.textToSpeech.speak(message.text)
                                    }
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
                    VStack(spacing: 6) {
                        WaveformView(levels: viewModel.speechToText.micLevels)
                        Text(String(format: "%02d:%02d",
                                    viewModel.speechToText.recordingSeconds / 60,
                                    viewModel.speechToText.recordingSeconds % 60))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 40)

                    Text(viewModel.speechToText.currentText)     // transkrip live tetap berguna
                        .font(.shakyComicBold(size: 19)).bold()
                }

                if viewModel.isPreparing {
                    ProgressView("Menyiapkan pelanggan... (pertama kali bisa lama)")
                        .padding(.bottom, 24)
                } else if !viewModel.isSessionOver {
                    VStack(spacing: 12) {
                        Text("TEKAN DAN TAHAN UNTUK BERBICARA")
                            .font(.shakyComicBold(size: 14))
                            .foregroundStyle(Color("Secondary"))

                        HoldToTalkButton { pressing in
                            if pressing {
                                Task { await viewModel.speechToText.startPlaying() }
                            } else {
                                viewModel.speechToText.stopPlaying()
                            }
                        }
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
                                isLevelScreen = false
                                showLoading = true
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.startSession()
            }
        }
        .fullScreenCover(isPresented: $showLoading) {
            LoadingScreen() {
                showLoading = false
                showHasil = true
            }
        }
        .sheet(isPresented: $showHasil) {
            ResultScreen(
                isLevelScreen: false,
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
                feedback: viewModel.feedbackText ?? "",
                transcript: viewModel.sessionTranscript ?? ""
            ))
        }
        .overlay(alignment: .bottom) {
            if isError {
                AppSnackbar(errorMessage: errorText, type: .error, isPresented: $isError)
            }
            
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.errorMessage) { _, new in showError(new) }
        .onChange(of: viewModel.speechToText.errorMessage) { _, new in showError(new) }
        .onChange(of: viewModel.textToSpeech.errorMessage) { _, new in showError(new) }
        .overlay {
            AppAlert(
                isPresented: $showQuitAlert,
                message: "APAKAH ANDA AKAN MENGAKHIRI TES INI ?",
                primaryButtonTitle: "YA",
                primaryAction: {
                    viewModel.endSession()
                    isPresented = false
                }
            )
        }
    }
    
}



#Preview {
    RolePlayScreen(isPresented: .constant(true))
}
