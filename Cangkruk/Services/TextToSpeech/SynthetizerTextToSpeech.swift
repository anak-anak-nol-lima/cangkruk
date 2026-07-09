//
//  SynthetizerTextToSpeech.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI
import Speech
import AVFoundation

// interface for the textToSpeech functionality
// need to implement the functionality specified
protocol ITextToSpeech {
    func speak(_ text: String) throws
}


class SynthetizerTextToSpeech: ITextToSpeech {
    private let synthetizer = AVSpeechSynthesizer()
    
    // speak will accept text from the caller ( viewmodel )
    // it will initialize the audioSession with playback mode
    // it will filter the premium quality of the voice
    func speak(_ text: String) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getPremiumQuality()
        synthetizer.speak(utterance)
    }
    
    
    // getPremiumQuality will filtering all the damayanti voices and get the most premium quality it can get
    func getPremiumQuality() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let filteredVoice = voices.filter { voice in
            voice.name == "Damayanti"
        }
        let bestQuality = filteredVoice.max { current, next in
            // it comparing the value
            // if current < next and next is bigger, then current = next ( next loop current will be next )
            current.quality.rawValue < next.quality.rawValue
        }
        return bestQuality ?? AVSpeechSynthesisVoice(language: "id-ID")
    }
}
