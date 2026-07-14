//
//  ChatMessage.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//

import Foundation


enum ChatRole{
    case barista
    case customer
}

struct ChatMessage: Identifiable, Equatable{
    let id = UUID()
    let role: ChatRole
    let text: String
}



