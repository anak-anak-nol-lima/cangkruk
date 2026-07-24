//
//  Feedback.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 14/07/26.
//

import Foundation
import SwiftData


struct FeedbackRequest: Codable {
    var transcript: String
}

@Model
final class FeedbackResult {
    var id: UUID
    var date: Date
    var levelNumber: Int
    var scenarioName: String
    var summary: String
    var feedback: String
    var duration: Int
    // log percakapan lengkap sesi ini — belum tampil di UI,
    // disimpan untuk halaman detail nanti
    var transcript: String = ""

    init(
        levelNumber: Int,
        scenarioName: String,
        summary: String,
        feedback: String,
        transcript: String = "",
        date: Date = .now,
        duration: Int
    ) {
        self.id = UUID()
        self.date = date
        self.levelNumber = levelNumber
        self.scenarioName = scenarioName
        self.summary = summary
        self.feedback = feedback
        self.transcript = transcript
        self.duration = duration
    }
}
