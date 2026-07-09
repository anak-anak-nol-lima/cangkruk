//
//  SpeechToTextViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI


@MainActor
@Observable
class SpeechToTextViewModel {
    let audioEngineManager = AudioEngineManager()
    let transcriptionManager = TranscriptionManager()
    
    var errorMessage: String?
    var isPlaying = false
    var currentText = ""
    var finalText = ""
    var result: [String] = []
    
    // requestPermission will requesting microphone & speech permission
    func requestPermission() async -> Bool {
        let micPermission = await audioEngineManager.setupPermission()
        let speechPermission = await transcriptionManager.setupPermission()
        return micPermission && speechPermission
    }
    
    // processMic will running the start playing if it's not play state
    // will run the stop play when click again ( play state )
    func processMic() {
        Task {
            if isPlaying {
                stopPlaying()
            } else {
                await startPlaying()
            }
        }
    }
        
    // startPlaying will run several things such as requesting permission
    // will setting up the audioSession for triggering record mode
    // will also start the engine faucet ( for the buffer flowing in )
    // finally will run startTranscribe that run the recognizer when getting the processBuffer
    func startPlaying() async {
        guard await requestPermission() else {
            errorMessage = "Permission Denied"
            return
        }
        
        do {
            isPlaying = true
            
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
                        self.finalText = ""
                        self.currentText = ""
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    // stopPlaying will stopping the audio & speech functionality
    func stopPlaying() {
        audioEngineManager.stopAudioEngine()
        transcriptionManager.stopTranscribe()
        isPlaying = false
    }
}
