//
//  Config.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftUI


struct Config {
    static func stringValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return ""
        }
        
        return value
    }
}
