//
//  CryptoManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftUI
import CryptoKit


class CryptoManager: CryptoProtocol {
    var key: String
    
    init(key: String) {
        self.key = key
    }
        
    func encrypt(data: String) -> String {
        guard data != "" else { return "" }
        
        let data = Data(data.utf8)
        do {
            guard let keyData = Data(base64Encoded: key) else { return "" }
            let sealedBox = try AES.GCM.seal(data, using: SymmetricKey(data: keyData))
            guard let encryptedData = sealedBox.combined else { return "" }
            return encryptedData.base64EncodedString()
        } catch {
            print(error)
            return ""
        }
    }
    
    func verify(data: String, text: String) -> Bool {
        do {
            guard let d = Data(base64Encoded: data) else { return false }
            guard let keyData = Data(base64Encoded: key) else { return false }

            let sealedBox = try AES.GCM.SealedBox(combined: d)
            let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
            
            let decrypted = String(decoding: decryptedData, as: UTF8.self)
            return decrypted == text
        } catch {
            return false
        }
    }
}
