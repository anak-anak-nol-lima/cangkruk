//
//  TrainingFile.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import Foundation
import SwiftData

enum TrainingFileSection: String, Codable {
    case sop
    case resep
}

@Model
final class TrainingFile {
    var id: UUID
    var name: String
    var date: Date
    var section: String
    var storedFileName: String
    var extractedText: String?
    var summarizedText: String? // untuk save hasil output

    init(
        name: String,
        date: Date = .now,
        section: TrainingFileSection,
        storedFileName: String,
        extractedText: String? = nil,
        summarizedText: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.section = section.rawValue
        self.storedFileName = storedFileName
        self.extractedText = extractedText
        self.summarizedText = summarizedText
    }
}
