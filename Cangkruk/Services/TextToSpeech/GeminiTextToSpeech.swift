//
//  GeminiTextToSpeech.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 24/07/26.
//

import SwiftUI
import AVFoundation

struct GeminiTTSInput: Codable {
    var text: String
}

struct GeminiTTSVoice: Codable {
    var languageCode: String
    var name: String
}

struct GeminiTTSRequest: Codable {
    var input: GeminiTTSInput
    var voice: GeminiTTSVoice
    var audioConfig: GeminiEncoding
}

struct GeminiEncoding: Codable {
    var audioEncoding: String
}

struct GeminiTTSResponse: Codable {
    var audioContent: String
}

class GeminiTextToSpeech: TextToSpeechProtocol {
    var networkManager: NetworkManager
    private var audioPlayer: AVAudioPlayer?

    init(networkManager: NetworkManager = NetworkManager(host: "https://\(Config.stringValue(forKey: "GEMINI_HOST"))")) {
        self.networkManager = networkManager
    }
    
    func geminiSpeakProcess(_ text: String) async throws -> String {
        let ttsInput = GeminiTTSInput(
            text: text
        )
        let voice = GeminiTTSVoice(
            languageCode: "id-ID",
            name: "id-ID-Chirp3-HD-Despina"
        )
        
        let audioConfig = GeminiEncoding(audioEncoding: "MP3")
        let ttsRequest = GeminiTTSRequest(input: ttsInput, voice: voice, audioConfig: audioConfig)
        let body = try JSONEncoder().encode(ttsRequest)
        
        guard let data = try await networkManager.post(path: "/v1/text:synthesize?key=\(Config.stringValue(forKey: "GEMINI_API_KEY"))", req: body) else {
            return ""
        }
        
        let res = try JSONDecoder().decode(GeminiTTSResponse.self, from: data)
        return res.audioContent
    }
    
    // speak will call the gemini text to speech restapi
    func speak(_ text: String) async throws {
        do {
            let audio = try await geminiSpeakProcess(text)
            guard let audioData = Data(base64Encoded: audio) else {
                return
            }
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioPlayer = try AVAudioPlayer(data: audioData)
            self.audioPlayer?.play()
        } catch {
            print("Error \(error)")
        }
    }
}
