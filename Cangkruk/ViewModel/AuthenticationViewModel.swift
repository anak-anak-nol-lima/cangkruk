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

    // email currently being reset via the forgot-password flow, set by verifyEmailForReset
    var resetEmail: String?
    
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
    // will find the email match the specified email
    func getUser(context: ModelContext, email: String) -> User? {
        let predicate = #Predicate<User> { user in
            user.email == email
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
    
    // login will validate to reject if the email or the password empty
    // will get the user exist or no based on the email
    // will verify the password
    // will return the user if all cases fine
    func login(context: ModelContext, email: String, password: String) async -> User? {
        errorMessage = ""
        successMessage = ""
        isLoading = true
        defer { isLoading = false } // run this every function call end

        try? await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage

        if email.isEmpty || password.isEmpty {
            errorMessage = "email and password cannot be empty"
            isError = true
            return nil
        }
        
        guard let user = getUser(context: context, email: email.lowercased()) else {
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
    
    
    // register will validate to reject if the email or the password empty
    // will encrypt the password
    // will return the user if all cases fine
    func register(context: ModelContext, email: String, password: String) async -> User? {
        errorMessage = ""
        successMessage = ""
        isLoading = true
        defer { isLoading = false } // run this every function call end

        try? await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage

        if email.isEmpty || password.isEmpty {
            errorMessage = "email and password cannot be empty"
            isError = true
            return nil
        }

        guard isValidEmail(email) else {
            errorMessage = "Email tidak ditemukan"
            isError = true
            return nil
        }

        let encryptedPassword = cryptoManager.encrypt(data: password.lowercased())
        let user = User(email: email.lowercased(), password: encryptedPassword)
        context.insert(user)
        successMessage = "User successfully created"
        return user
    }

    // isValidEmail checks that the given string matches a basic user@domain.tld shape
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    // verifyEmailForReset checks whether a user with the given email exists.
    // on success, stores the email in `resetEmail` so resetPassword knows which user to update.
    func verifyEmailForReset(context: ModelContext, email: String) -> Bool {
        errorMessage = ""
        let normalizedEmail = email.lowercased()

        guard getUser(context: context, email: normalizedEmail) != nil else {
            errorMessage = "Email tidak ditemukan"
            isError = true
            return false
        }

        resetEmail = normalizedEmail
        return true
    }

    // resetPassword overwrites the password of the user matched by `resetEmail`
    // will reject if there's no resetEmail set, the user can't be found, or the new password is empty
    func resetPassword(context: ModelContext, newPassword: String) async -> User? {
        errorMessage = ""
        successMessage = ""
        isLoading = true
        defer { isLoading = false } // run this every function call end

        try? await Task.sleep(for: .milliseconds(50)) // sleep for allow the observer to reset the errorMessage

        guard let email = resetEmail else {
            errorMessage = "No email to reset"
            isError = true
            return nil
        }

        if newPassword.isEmpty {
            errorMessage = "Password cannot be empty"
            isError = true
            return nil
        }

        guard let user = getUser(context: context, email: email) else {
            errorMessage = "Email tidak ditemukan"
            isError = true
            return nil
        }

        user.password = cryptoManager.encrypt(data: newPassword.lowercased())

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save new password"
            isError = true
            return nil
        }

        successMessage = "Password reset successfully"
        resetEmail = nil
        return user
    }
    
    func logout() {
        errorMessage = nil
        successMessage = nil
        resetEmail = nil
        isLoading = false
        isError = false
    }
}
