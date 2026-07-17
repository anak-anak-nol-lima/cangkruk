//
//  TextToSpeechViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

@Observable
class TextToSpeechViewModel {
    let textToSpeech: TextToSpeechProtocol
    var errorMessage: String?
    
    init(textToSpeech: TextToSpeechProtocol = SynthetizerTextToSpeech()) {
        self.textToSpeech = textToSpeech
    }
    
    
    func speak(_ text: String) async {
        errorMessage = ""
        
        do {
            try textToSpeech.speak(text)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
