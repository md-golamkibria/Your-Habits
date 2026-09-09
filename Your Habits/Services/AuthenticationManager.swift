//
//  AuthenticationManager.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation
import SwiftUI
import CryptoKit

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let userDefaultsKey = "current_user"
    private let registeredUsersKey = "registered_users"
    
    init() {
        loadUser()
    }
    
    func signUp(name: String, email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Basic validation
            if name.isEmpty || email.isEmpty || password.isEmpty {
                self.errorMessage = "Please fill in all fields"
                self.isLoading = false
                return
            }
            
            if !self.isValidEmail(email) {
                self.errorMessage = "Please enter a valid email address"
                self.isLoading = false
                return
            }
            
            if password.count < 6 {
                self.errorMessage = "Password must be at least 6 characters"
                self.isLoading = false
                return
            }
            
            // Check if user already exists
            if self.userExists(email: email) {
                self.errorMessage = "An account with this email already exists"
                self.isLoading = false
                return
            }
            
            // Create new user account
            let hashedPassword = self.hashPassword(password)
            let userAccount = UserAccount(email: email, name: name, hashedPassword: hashedPassword)
            
            // Save to registered users
            self.saveUserAccount(userAccount)
            
            // Create user object for the session
            let newUser = User(email: email, name: name)
            self.currentUser = newUser
            self.saveUser(newUser)
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Basic validation
            if email.isEmpty || password.isEmpty {
                self.errorMessage = "Please fill in all fields"
                self.isLoading = false
                return
            }
            
            if !self.isValidEmail(email) {
                self.errorMessage = "Please enter a valid email address"
                self.isLoading = false
                return
            }
            
            // Check if user exists and validate credentials
            guard let userAccount = self.getUserAccount(email: email) else {
                self.errorMessage = "No account found with this email address. Please sign up first."
                self.isLoading = false
                return
            }
            
            // Verify password
            let hashedPassword = self.hashPassword(password)
            if userAccount.hashedPassword != hashedPassword {
                self.errorMessage = "Invalid email or password"
                self.isLoading = false
                return
            }
            
            // Login successful - create user session
            let user = User(email: userAccount.email, name: userAccount.name)
            self.currentUser = user
            self.saveUser(user)
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func userExists(email: String) -> Bool {
        return getUserAccount(email: email) != nil
    }
    
    private func getUserAccount(email: String) -> UserAccount? {
        let registeredUsers = getRegisteredUsers()
        return registeredUsers.first { $0.email.lowercased() == email.lowercased() }
    }
    
    private func saveUserAccount(_ userAccount: UserAccount) {
        var registeredUsers = getRegisteredUsers()
        registeredUsers.append(userAccount)
        
        if let encoded = try? JSONEncoder().encode(registeredUsers) {
            UserDefaults.standard.set(encoded, forKey: registeredUsersKey)
        }
    }
    
    private func getRegisteredUsers() -> [UserAccount] {
        if let userData = UserDefaults.standard.data(forKey: registeredUsersKey),
           let users = try? JSONDecoder().decode([UserAccount].self, from: userData) {
            return users
        }
        return []
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUser() {
        if let user = loadSavedUser() {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func loadSavedUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            return user
        }
        return nil
    }
}

// User account structure for storing credentials
struct UserAccount: Codable {
    let email: String
    let name: String
    let hashedPassword: String
    let createdAt: Date
    
    init(email: String, name: String, hashedPassword: String) {
        self.email = email
        self.name = name
        self.hashedPassword = hashedPassword
        self.createdAt = Date()
    }
}