//
//  FakeNetworkManager.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 16/07/26.
//

import SwiftUI
import Testing

@testable import Cangkruk


class FakeNetworkManager: NetworkManagerProtocol {
    // MARK: Spy to track get
    var isGetCalled: Int = 0
    var isPostCalled: Int = 0
    
    func get(path: String) async throws -> Data? {
        isGetCalled += 1
        return nil
    }
    
    func post(path: String, req: Data) async throws -> Data? {
        isPostCalled += 1
        return nil
    }
}
