//
//  SpeechToTextViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

@Observable
class SpeechToTextViewModel {
    let audioEngineManager: AudioEngineProtocol
    let transcriptionManager: TranscriptionManagerProtocol
    
    var errorMessage: String?
    var isPlaying: Bool
    var currentText = ""
    var finalText = ""
    var result: [String] = []
    var onFinalTranscript: ((String) async -> Void)?
    
    init(
        audioEngineManager: AudioEngineProtocol = AudioEngineManager(),
        transcriptionManager: TranscriptionManagerProtocol = TranscriptionManager(),
        isPlaying: Bool = false
    ) {
        self.audioEngineManager = audioEngineManager
        self.transcriptionManager = transcriptionManager
        self.isPlaying = isPlaying
        
        // initialize self.requestPermission to ask whenever the roleplay initialized
        Task {
            await self.requestPermission()
        }
    }
    
    // requestPermission will requesting microphone & speech permission
    func requestPermission() async -> Bool {
        let micPermission = await audioEngineManager.setupPermission()
        let speechPermission = await transcriptionManager.setupPermission()
        return micPermission && speechPermission
    }
    
    // processMic will running the start playing if it's not play state
    // will run the stop play when click again ( play state )
    func processMic() async {
        if isPlaying {
            stopPlaying()
        } else {
            await startPlaying()
        }
    }
        
    // startPlaying will run several things such as requesting permission
    // will setting up the audioSession for triggering record mode
    // will also start the engine faucet ( for the buffer flowing in )
    // finally will run startTranscribe that run the recognizer when getting the processBuffer
    func startPlaying() async {
        errorMessage = "" // reset error message every call

        guard await requestPermission() else {
            errorMessage = "Permission Denied"
            return
        }
        
        do {
            try audioEngineManager.setupAudioSession()
            try transcriptionManager.startTranscribe { [weak self] output in
                guard let self = self else { return }
                
                switch output {
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                case .success(let (value, isFinal)):
                    if isFinal {
                        // final will save the
                        self.finalText += value
                        self.result.append(self.finalText)
                        let finalTranscript = self.finalText
                        self.finalText = ""
                        self.currentText = ""
                        Task { await self.onFinalTranscript?(finalTranscript) }
                    } else {
                        // if not final just render the text somewhere
                        self.currentText = value
                    }
                }
            }
            
            try audioEngineManager.startAudioEngine { [weak self] buffer in
                guard let self = self else { return }
                self.transcriptionManager.processAudioBuffer(buffer)
            }
            
            isPlaying = true
        } catch {
            errorMessage = error.localizedDescription
            isPlaying = false
        }
    }
    
    
    // stopPlaying will stopping the audio & speech functionality
    func stopPlaying() {
        audioEngineManager.stopAudioEngine()
        transcriptionManager.stopTranscribe()
        isPlaying = false
    }
}
