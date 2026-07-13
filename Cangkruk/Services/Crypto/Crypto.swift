//
//  Crypto.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftUI


protocol CryptoProtocol {
    func encrypt(data: String) -> String
    func verify(data: String, text: String) -> Bool
}
