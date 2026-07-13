//
//  CryptoTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import Testing
import CryptoKit

@testable import Cangkruk
internal import Foundation


class CryptoTests {
    let text = "Hello, World!"
    let key = "YEEM5yWbd6JFbRJjku/1z1OM6cPeArraNy+/HTZAWgo="
    
    @Test("encrypt will output the AES-256 hash")
    func encrypt() {
        let cm = CryptoManager(key: key)
        let value = cm.encrypt(data: text)
        #expect(value.isEmpty == false)
    }
    
    @Test("verify will do verify on the AES-256 hash")
    func verify() {
        let cm = CryptoManager(key: key)
        let value = cm.encrypt(data: text)
        let verify = cm.verify(data: value, text: text)
        #expect(verify == true)
    }
    
    @Test("verifyFailed will do verify on the AES-256 hash")
    func verifyFailed() {
        let cm = CryptoManager(key: key)
        let value = cm.encrypt(data: text)
        let verify = cm.verify(data: value, text: "wrong password")
        #expect(verify == false)
    }
}
