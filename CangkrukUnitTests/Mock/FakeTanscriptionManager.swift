//
//  FakeTanscriptionManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing
import AVFoundation

@testable import Cangkruk


class FakeTanscriptionManager: TranscriptionManagerProtocol {
    // MARK: - stubs
    var permission: Bool = true
    var startTranscribeError: Error?
    
    
    // MARK: - spy
    var setupPermissionCalled: Int = 0
    var startTranscribeCalled: Int = 0
    var processAudioBufferCalled: Int = 0
    var stopTranscribeCalled: Int = 0
    
    
    // MARK: - fake
    // fake for a function that we want to fake the response to manipulate it
    var fakeOnResult: ((Result<(String, Bool), any Error>) -> Void)?

    
    func setupPermission() async -> Bool {
        setupPermissionCalled += 1
        return permission
    }
    
    func startTranscribe(onResult: @escaping (Result<(String, Bool), any Error>) -> Void) throws {
        startTranscribeCalled += 1
        
        if let startTranscribeError {
            throw startTranscribeError
        }
        
        fakeOnResult = onResult
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        processAudioBufferCalled += 1
    }
    
    func stopTranscribe() {
        stopTranscribeCalled += 1
    }
}
