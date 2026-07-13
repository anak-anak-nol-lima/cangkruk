//
//  AuthenticationViewModelTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftData
import Testing

@testable import Cangkruk

@MainActor
struct AuthenticationViewModelTests {
    
    @Test("login successfully responded")
    func loginSuccess() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        
        let username = "johndoe"
        let password = "john123"
        
        let cryptoManager = CryptoManager(key: "YEEM5yWbd6JFbRJjku/1z1OM6cPeArraNy+/HTZAWgo=")
        let vm = AuthenticationViewModel(cryptoManager: cryptoManager)
        
        let context = container.mainContext
        
        // register first
        _ = await vm.register(
            context: context,
            username: username,
            password: password
        )
         
        // try login
        let user = await vm.login(
            context: context,
            username: username,
            password: password
        )
        
        #expect(user?.username == username)
        #expect(vm.successMessage == "Login successfully")
    }
    
    
    @Test("login failed - wrong password")
    func loginFailed() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        
        let username = "johndoe"
        let password = "john123"
        
        let cryptoManager = CryptoManager(key: "YEEM5yWbd6JFbRJjku/1z1OM6cPeArraNy+/HTZAWgo=")
        let vm = AuthenticationViewModel(cryptoManager: cryptoManager)
        
        let context = container.mainContext
        
        // register first
        _ = await vm.register(
            context: context,
            username: username,
            password: password
        )
         
        // try login
        let user = await vm.login(
            context: context,
            username: username,
            password: "password"
        )
        
        #expect(user == nil)
        #expect(vm.errorMessage == "Invalid password")
    }
    
    
    @Test("register successfully created")
    func registerSuccess() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        
        let username = "johndoe"
        let password = "john123"
        
        let cryptoManager = CryptoManager(key: "YEEM5yWbd6JFbRJjku/1z1OM6cPeArraNy+/HTZAWgo=")
        let vm = AuthenticationViewModel(cryptoManager: cryptoManager)
        
        let context = container.mainContext
                
        let user = await vm.register(
            context: context,
            username: username,
            password: password
        )
        
        #expect(user?.username == username)
        #expect(vm.successMessage == "User successfully created")
    }
}
