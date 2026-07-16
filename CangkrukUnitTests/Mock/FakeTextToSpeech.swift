//
//  FakeTextToSpeech.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing

@testable import Cangkruk


class FakeTextToSpeech: TextToSpeechProtocol {
    // MARK: - stub
    var speakError: Error?
    
    // MARK: - spy
    var speakCalled: Int = 0
    
    func speak(_ text: String) throws {
        speakCalled += 1
        if let speakError {
            throw speakError
        }
    }
}

struct FakeError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
