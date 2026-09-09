//
//  AuthViewModel.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation
import SwiftUI
import CryptoKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let registeredUsersKey = "registered_users_auth_vm"
    
    init() {
        // Check if user is already logged in
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // Check UserDefaults for a saved user session
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Basic validation
        if email.isEmpty || password.isEmpty {
            self.errorMessage = "Please enter both email and password"
            self.isLoading = false
            return
        }
        
        if !isValidEmail(email) {
            self.errorMessage = "Please enter a valid email address"
            self.isLoading = false
            return
        }
        
        // Check if user exists and validate credentials
        guard let userAccount = getUserAccount(email: email) else {
            self.errorMessage = "No account found with this email address. Please sign up first."
            self.isLoading = false
            return
        }
        
        // Verify password
        let hashedPassword = hashPassword(password)
        if userAccount.hashedPassword != hashedPassword {
            self.errorMessage = "Invalid email or password"
            self.isLoading = false
            return
        }
        
        // Login successful - create user session
        let user = User(
            email: userAccount.email,
            name: userAccount.name,
            points: 150,
            level: 2,
            badges: [
                Badge(
                    name: "Welcome Back",
                    description: "Successfully logged in to your account",
                    iconName: "person.circle.fill",
                    category: .achievement
                )
            ],
            totalCO2Saved: 12.5,
            totalWaterSaved: 150.0,
            totalTreesPreserved: 0.025
        )
        
        // Save user session to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        self.currentUser = user
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Basic validation
        if name.isEmpty || email.isEmpty || password.isEmpty {
            self.errorMessage = "Please fill in all fields"
            self.isLoading = false
            return
        }
        
        if !isValidEmail(email) {
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
        if userExists(email: email) {
            self.errorMessage = "An account with this email already exists"
            self.isLoading = false
            return
        }
        
        // Create new user account
        let hashedPassword = hashPassword(password)
        let userAccount = UserAccountVM(email: email, name: name, hashedPassword: hashedPassword)
        
        // Save to registered users
        saveUserAccount(userAccount)
        
        // Create user session
        let user = User(
            email: email,
            name: name,
            badges: [
                Badge(
                    name: "Welcome!",
                    description: "Welcome to Your Habits! Start your eco-journey today.",
                    iconName: "hand.wave.fill",
                    category: .achievement
                )
            ]
        )
        
        // Save user session to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        self.currentUser = user
        self.isAuthenticated = true
        self.isLoading = false
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func updateUser(_ user: User) {
        self.currentUser = user
        
        // Save updated user to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    // MARK: - Private Helper Methods
    
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
    
    private func getUserAccount(email: String) -> UserAccountVM? {
        let registeredUsers = getRegisteredUsers()
        return registeredUsers.first { $0.email.lowercased() == email.lowercased() }
    }
    
    private func saveUserAccount(_ userAccount: UserAccountVM) {
        var registeredUsers = getRegisteredUsers()
        registeredUsers.append(userAccount)
        
        if let encoded = try? JSONEncoder().encode(registeredUsers) {
            UserDefaults.standard.set(encoded, forKey: registeredUsersKey)
        }
    }
    
    private func getRegisteredUsers() -> [UserAccountVM] {
        if let userData = UserDefaults.standard.data(forKey: registeredUsersKey),
           let users = try? JSONDecoder().decode([UserAccountVM].self, from: userData) {
            return users
        }
        return []
    }
}

// User account structure for storing credentials (separate from the one in AuthenticationManager)
struct UserAccountVM: Codable {
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