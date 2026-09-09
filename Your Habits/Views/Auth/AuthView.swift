//
//  AuthView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isSignUpMode = false
    
    var body: some View {
        if authViewModel.isAuthenticated {
            ContentView()
                .environmentObject(authViewModel)
        } else {
            authenticationView
        }
    }
    
    private var authenticationView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Logo/Header
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("Your Habits")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Build sustainable habits for a better tomorrow")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                    
                    // Auth Form
                    VStack(spacing: 20) {
                        if isSignUpMode {
                            SignUpForm(authViewModel: authViewModel)
                        } else {
                            SignInForm(authViewModel: authViewModel)
                        }
                        
                        // Toggle between Sign In/Sign Up
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSignUpMode.toggle()
                            }
                        }) {
                            HStack {
                                Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text(isSignUpMode ? "Sign In" : "Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SignInForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign In")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
        }
    }
}

struct SignUpForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Full Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.name)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                Text("Passwords don't match")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await authViewModel.signUp(name: name, email: email, password: password)
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty || password != confirmPassword)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}