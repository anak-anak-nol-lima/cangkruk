//
//  SpeechToTextViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//
    
import SwiftUI
import AVFoundation

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
    var micLevels: [CGFloat] = []
    
    var recordingSeconds: Int = 0
    private var recordingTimer: Task<Void, Never>?
    
    
    
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
                let level = Self.level(from: buffer)
                DispatchQueue.main.async{
                    self.micLevels.append(level)
                    if self.micLevels.count>40{
                        self.micLevels.removeFirst()
                    }
                }
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
    nonisolated private static func level (from buffer: AVAudioPCMBuffer) -> CGFloat {
        guard let data = buffer.floatChannelData?[0] else {
            return 0
        }
        let n = Int (buffer.frameLength)
        guard n > 0 else {return 0 }
        var sum: Float = 0
        for i in 0 ..< n {
            sum += data [i] * data[i]
        }
        let rms = sqrt(sum/Float (n))
        let db = 20*log10 (max (rms, 0.0001))
        let normalized = (db+50)/40
        return CGFloat(min(max(normalized,0.05),1))
        
    }
}
