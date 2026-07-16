//
//  ChatMessage.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//

import Foundation


enum ChatRole: String, Codable {
    case barista
    case customer
}

struct ChatMessage: Codable, Identifiable, Equatable {
    var id = UUID()
    let role: ChatRole
    let text: String
}

