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
    var email: String
    var password: String
    var created: Date
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.created = .now
    }
}
