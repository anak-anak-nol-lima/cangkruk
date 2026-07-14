//
//  AudioEngineManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import AVFoundation

protocol AudioEngineProtocol {
    func setupAudioSession() throws
    func setupPermission() async -> Bool
    func startAudioEngine(onBuffer: @escaping(AVAudioPCMBuffer) -> Void) throws
    func stopAudioEngine()
}

class AudioEngineManager: AudioEngineProtocol {
    private let engine = AVAudioEngine()
    private var tapInstalled = false
    
    
    // setting up audio session ( for setting to be record mode )
    func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .duckOthers])
        try session.setActive(true)
    }
    
    // setup permission will returning boolean to parent
    func setupPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    // startAudioEngine will start open the audio that accepting via "tap" water-like buffer
    // it will going to the "buffer" variable that we passed into the caller callback onBuffer
    func startAudioEngine(onBuffer: @escaping(AVAudioPCMBuffer) -> Void) throws {
        // if it already installed don't re-install to prevent un-close stream
        guard !tapInstalled else { return }
        
        let input = engine.inputNode
        input.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: .none
        ) { buffer, _ in
            onBuffer(buffer)
        }
        
        engine.prepare()
        try engine.start()
        tapInstalled = true
    }
    
    // stopAudioEngine will stop any existing open engine that on port "0" which is on microphone
    // will clear all the unused functionality
    func stopAudioEngine() {
        guard tapInstalled else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        tapInstalled = false
    }
}
