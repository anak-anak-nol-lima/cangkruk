//
//  AIResponse.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 15/07/26.
//

import Foundation
import FoundationModels

@Generable
struct TrainingMaterialResponse: Codable {
    @Guide(description: "Learning material title for a new barista")
    var title: String

    @Guide(description: "Material sections with headings and bullet points")
    var sections: [TrainingSection]

    @Guide(description: "Full learning material text in Markdown format")
    var rawMarkdown: String
}

@Generable
struct TrainingSection: Codable, Identifiable {
    var id: UUID { UUID() }

    @Guide(description: "Section heading, for example SOP or a menu category")
    var heading: String

    @Guide(description: "Actionable learning bullet points that are easy to memorize")
    var bulletPoints: [String]
}

struct RolePlayFeedbackResponse: Codable {
    let summary: String
    let feedback: String
}
