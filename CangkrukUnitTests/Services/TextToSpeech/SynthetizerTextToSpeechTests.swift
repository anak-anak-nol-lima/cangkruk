//
//  SynthetizerTextToSpeechTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing
import AVFoundation

@testable import Cangkruk

struct SynthetizerTextToSpeechTests {
    @Test("filterPremiumQuality will filtering the premium audio quality to get the highest quality")
    func filterPremiumQuality() {
        let voices = [
            StubVoice(name: "Damayanti", quality: .premium),
            StubVoice(name: "Damayanti", quality: .enhanced),
            StubVoice(name: "Damayanti", quality: .default),
        ]
        
        let synt = SynthetizerTextToSpeech()
        let res = synt.filterPremiumQuality(voices: voices)
        
        #expect(res?.quality == .premium) // the correct will be premium
    }
}
