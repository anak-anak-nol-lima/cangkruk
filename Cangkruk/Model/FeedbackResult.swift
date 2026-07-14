//
//  FeedbackResult.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import Foundation
import SwiftData

@Model
final class FeedbackResult {
    var id: UUID
    var date: Date
    var levelNumber: Int
    var scenarioName: String
    var summary: String
    var feedback: String

    init(
        levelNumber: Int,
        scenarioName: String,
        summary: String,
        feedback: String,
        date: Date = .now
    ) {
        self.id = UUID()
        self.date = date
        self.levelNumber = levelNumber
        self.scenarioName = scenarioName
        self.summary = summary
        self.feedback = feedback
    }
}
