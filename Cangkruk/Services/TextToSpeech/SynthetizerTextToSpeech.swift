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
protocol TextToSpeechProtocol {
    func speak(_ text: String) throws
}


class SynthetizerTextToSpeech: TextToSpeechProtocol {
    private let synthetizer = AVSpeechSynthesizer()
    
    // speak will accept text from the caller ( viewmodel )
    // it will initialize the audioSession with playback mode
    // it will filter the premium quality of the voice
    func speak(_ text: String) throws {
        let utterance = AVSpeechUtterance(string: text)
        let bestVoice = getPremiumQuality(voices: AVSpeechSynthesisVoice.speechVoices())
        utterance.voice = bestVoice
        synthetizer.speak(utterance)
    }
    
    // getPremiumQuality will get the filter voice
    // if none return anything that available
    func getPremiumQuality(voices: [AVSpeechSynthesisVoice]) -> AVSpeechSynthesisVoice? {
        let filteredVoice = filterPremiumQuality(voices: voices)
        return filteredVoice ?? AVSpeechSynthesisVoice(language: "id-ID")
    }
    
    // filterPremiumQuality will filtering all the damayanti voices and get the most premium quality it can get
    func filterPremiumQuality(voices: [AVSpeechSynthesisVoice]) -> AVSpeechSynthesisVoice? {
        let filteredVoice = voices.filter { voice in
            voice.name == "Damayanti"
        }
        let bestQuality = filteredVoice.max { current, next in
            // it comparing the value
            // if current < next and next is bigger, then current = next ( next loop current will be next )
            current.quality.rawValue < next.quality.rawValue
        }
        return bestQuality
    }
}
