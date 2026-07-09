//
//  TranscriptionManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import AVFoundation
import Speech

enum TranscriptionError: Error {
    case failedToInitialize,
        failedToTranscribe,
        failedToStart
}

class TranscriptionManager {
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognizer: SFSpeechRecognizer?
    private var task: SFSpeechRecognitionTask?
    
    
    // setupPermission will get the speech permission for
    func setupPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    
    // startTranscribe will start to get the audiobuffer from the SFSpeechAudioBufferRecognitionRequest
    // it will do the recognizer to get the actual value from the buffer by using recognitionTask
    func startTranscribe(onResult: @escaping (Result<(String, Bool), Error>) -> Void) throws {
        if recognizer == nil {
            recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id_ID"))
        }
        
        guard let recognizer, recognizer.isAvailable else {
            throw TranscriptionError.failedToInitialize
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        request?.addsPunctuation = true
        request?.taskHint = .dictation
        
        
        task = recognizer.recognitionTask(with: request!) { (res, err) in
            if err != nil {
                onResult(.failure(err!))
                return
            }
            
            guard let res else { return }
            onResult(.success((res.bestTranscription.formattedString, res.isFinal)))
        }
    }
    
    // processAudioBuffer will get buffer and push it to the SFSpeechAudioBufferRecognitionRequest
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        request?.append(buffer)
    }
    
    
    // stopTranscribe will stopping to passed the buffer into the SFSpeechAudioBufferRecognitionRequest
    func stopTranscribe() {
        request?.endAudio()
    }
}
