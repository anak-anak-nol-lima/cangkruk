//
//  RolePlayScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI


struct RolePlayScreen: View {
    // MARK: - Binding
    @Binding var isPresented: Bool
    
    // MARK: - ViewModel
    @State private var speechToText: SpeechToTextViewModel = SpeechToTextViewModel()
    @State private var textToSpeech: TextToSpeechViewModel = TextToSpeechViewModel()
    
    // MARK: - State
    @State private var isError: Bool = false
    @State private var errorText: String = ""
    
    
    // MARK: - Internal Function
    private func showError(_ message: String?) {
        guard let message, !message.isEmpty else { return }
        errorText = message
        isError = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .onTapGesture {
                            isPresented = false
                        }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                
                VStack {
                    ForEach(speechToText.result.indices, id: \.self) { idx in
                        
                        let speech = speechToText.result[idx]
                        
                        VStack {
                            Text(speech)
                                .foregroundStyle(.white)
                                .font(.body)
                                .bold()
                        }
                        .padding()
                        .background(.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            textToSpeech.speak(speech)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            VStack {
                Spacer()
                
                if speechToText.isPlaying {
                    Text("Currently recording the text!")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.red)
                    
                    Text(speechToText.currentText)
                        .font(.caption)
                        .bold()
                }
                
                RecordButton() {
                    speechToText.processMic()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if isError {
                AppSnackbar(errorMessage: errorText, type: .error, isPresented: $isError)
            }
        }
        .onChange(of: speechToText.errorMessage) { _, newValue in
            showError(newValue)
        }
        .onChange(of: textToSpeech.errorMessage) { _, newValue in
            showError(newValue)
        }
    }
}


#Preview {
    RolePlayScreen(isPresented: .constant(true))
}
