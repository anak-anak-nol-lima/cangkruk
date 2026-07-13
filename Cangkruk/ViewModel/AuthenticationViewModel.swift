//
//  AuthenticationViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 13/07/26.
//

import SwiftUI
import SwiftData

@Observable
class AuthenticationViewModel {
    let cryptoManager: CryptoManager
    var errorMessage: String?
    var successMessage: String?
    var isLoading = false
    var isError = false
    
    init(
        cryptoManager: CryptoManager = CryptoManager(key: Config.stringValue(forKey: "CRYPTO_SECRET_KEY")),
        errorMessage: String? = nil
    ) {
        self.cryptoManager = cryptoManager
        self.errorMessage = errorMessage
    }
    
    // getLastUser will get the last user exist
    // the goal is to check if any user has been registered
    func getLastUser(context: ModelContext) -> User? {
        isLoading = true
        defer { isLoading = false } // run this every function call end
        
        var descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.created, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        let user = try? context.fetch(descriptor).first
        return user
    }
    
    
    // getUser will find the user inside the swift data based on the query
    // predicate will act as a where clause
    // will find the username match the specified username
    func getUser(context: ModelContext, username: String) -> User? {
        let predicate = #Predicate<User> { user in
            user.username == username
        }
        
        var descriptor = FetchDescriptor<User>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let users = try context.fetch(descriptor)
            return users.first
        } catch {
            errorMessage = error.localizedDescription
            isError = true
            return nil
        }
    }
    
    // login will validate to reject if the username or the password empty
    // will get the user exist or no based on the username
    // will verify the password
    // will return the user if all cases fine
    func login(context: ModelContext, username: String, password: String) async -> User? {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false } // run this every function call end

        try? await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage

        if username.isEmpty || password.isEmpty {
            errorMessage = "Username and password cannot be empty"
            isError = true
            return nil
        }
        
        guard let user = getUser(context: context, username: username.lowercased()) else {
            errorMessage = "User not found"
            isError = true
            return nil
        }
        
        let verify = cryptoManager.verify(data: user.password, text: password.lowercased())
        if !verify {
            errorMessage = "Invalid password"
            isError = true
            return nil
        }
        
        successMessage = "Login successfully"
        return user
    }
    
    
    // register will validate to reject if the username or the password empty
    // will encrypt the password
    // will return the user if all cases fine
    func register(context: ModelContext, username: String, password: String) async -> User? {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false } // run this every function call end

        try? await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage

        if username.isEmpty || password.isEmpty {
            errorMessage = "Username and password cannot be empty"
            isError = true
            return nil
        }
        
        let encryptedPassword = cryptoManager.encrypt(data: password.lowercased())
        let user = User(username: username.lowercased(), password: encryptedPassword)
        context.insert(user)
        
        successMessage = "User successfully created"
        return user
    }
}
