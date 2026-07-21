//
//  StubVoice.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import AVFoundation

class StubVoice: AVSpeechSynthesisVoice, @unchecked Sendable {
    // StubVoice will create a STUB object that inherit from the AVSpeechSynthesisVoice
    // the goal is to make this to be an object we can use for TESTING
    
    // we will use it like StubVoice(name: "Damayanti", quality: .premium)
    // unit testing will use this stub object to passed into the respective tested function to process
    
    private var _name: String
    private var _quality: AVSpeechSynthesisVoiceQuality

    init(name: String, quality: AVSpeechSynthesisVoiceQuality = .default) {
        self._name = name
        self._quality = quality
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var name: String {
        return _name
    }

    override var quality: AVSpeechSynthesisVoiceQuality {
        return _quality
    }
}
