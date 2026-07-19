//
//  LevelMaterial.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 19/07/26.
//

import SwiftUI
import SwiftData


// send to the network
struct LevelMaterialRequest: Codable {
    var systemPrompt: String
    
    enum CodingKeys: String, CodingKey {
        case systemPrompt = "system_prompt"
    }
}

// coming from the network
struct LevelMaterialResponse: Codable {
    var id: UUID
    var level: Int
    var title: String
    var body: String
}


// storing the network response to local data
@Model
class LevelMaterial {
    var id: UUID
    var level: Int
    var title: String
    var body: String
    
    init(level: Int, title: String, body: String) {
        self.id = UUID()
        self.level = level
        self.title = title
        self.body = body
    }
}
