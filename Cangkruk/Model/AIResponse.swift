//
//  AIResponse.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 15/07/26.
//

import Foundation

struct TrainingMaterialResponse: Codable {
    let title: String
    let sections: [TrainingSection]
    
    let rawMarkdown: String
}

struct TrainingSection: Codable, Identifiable {
    var id: UUID { UUID() }
    let heading: String
    let bulletPoints: [String]
}

struct RolePlayFeedbackResponse: Codable {
    let summary: String
    let feedback: String
}
