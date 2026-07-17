//
//  Feedback.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 18/07/26.
//

import SwiftUI

struct ReplyRequest: Codable {
    var systemPrompt: String
    var messages: [ChatMessage]
    
    
    enum CodingKeys: String, CodingKey {
        case systemPrompt = "system_prompt"
        case messages
    }
}

struct ReplyResponse: Decodable {
    let reply: String
}
