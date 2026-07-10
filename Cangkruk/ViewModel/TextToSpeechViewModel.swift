//
//  TextToSpeechViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

@MainActor
@Observable
class TextToSpeechViewModel {
    let textToSpeech: ITextToSpeech = SynthetizerTextToSpeech()
    var errorMessage: String?
    
    // speak will use the text here and passed into the synthetizer to process the audio
    func speak(_ text: String) {
        errorMessage = ""
        
        Task {
            do {
                try await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage
                try textToSpeech.speak(text)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
