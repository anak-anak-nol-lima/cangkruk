//
//  UserModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftUI
import SwiftData


@Model
class User {
    var username: String
    var password: String
    var created: Date
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.created = .now
    }
}
