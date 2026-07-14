//
//  LLMService.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 13/07/26.
//


import Foundation

enum LLMError: Error {
    case modelNotFound
    case noActiveSession
}


protocol ILLMService {
    func startsession (systemPrompt: String) async throws
    func send (_ baristaText:String) async throws -> String
    func endsession ()
}
