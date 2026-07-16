//
//  FakeAudioEngineManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing
import AVFoundation

@testable import Cangkruk


class FakeAudioEngineManager: AudioEngineProtocol {
    // MARK: - stubs
    // stubs responsible for an "output" that we define ( dummy ) for testing purposes
    var permission: Bool = true
    var setupAudioSessionError: Error?
    var startAudioEngineError: Error?
    
    
    // MARK: - spy
    // spy responsible for tracking the function called, to check if the function is actually submitted or no
    var setupAudioSessionCalled: Int = 0
    var setupPermissionCalled: Int = 0
    var startAudioEngineCalled: Int = 0
    var stopAudioEngineCalled: Int = 0
    
    
    func setupAudioSession() throws {
        setupAudioSessionCalled += 1
        
        if let setupAudioSessionError {
            throw setupAudioSessionError
        }
    }
    
    func setupPermission() async -> Bool {
        setupPermissionCalled += 1
        
        return permission
    }
    
    func startAudioEngine(onBuffer: @escaping (AVAudioPCMBuffer) -> Void) throws {
        startAudioEngineCalled += 1
        
        if let startAudioEngineError {
            throw startAudioEngineError
        }
    }
    
    func stopAudioEngine() {
        stopAudioEngineCalled += 1
    }
}
