//
//  WelcomeDashboardView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct WelcomeDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingOnboarding: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Header
                VStack(spacing: 12) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Welcome to Your Habits!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let user = authViewModel.currentUser {
                        Text("Hi \(user.name.components(separatedBy: " ").first ?? "there")! Ready to make a positive impact?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                // Getting Started Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "rocket.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Getting Started")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        OnboardingStepRow(
                            icon: "plus.circle.fill",
                            title: "Add Your First Habit",
                            description: "Start with small, achievable eco-friendly actions",
                            color: .green,
                            isCompleted: false
                        )
                        
                        OnboardingStepRow(
                            icon: "target",
                            title: "Set Daily Goals",
                            description: "Track your progress and stay motivated",
                            color: .orange,
                            isCompleted: false
                        )
                        
                        OnboardingStepRow(
                            icon: "flag.fill",
                            title: "Join Challenges",
                            description: "Compete with friends and earn rewards",
                            color: .purple,
                            isCompleted: false
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                // Impact Potential
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Your Potential Impact")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ImpactCard(
                            icon: "aqi.medium",
                            title: "CO₂ Reduction",
                            value: "0 kg",
                            subtitle: "Start tracking to see your impact!",
                            color: .green
                        )
                        
                        ImpactCard(
                            icon: "drop.fill",
                            title: "Water Saved",
                            value: "0 L",
                            subtitle: "Every drop counts",
                            color: .blue
                        )
                        
                        ImpactCard(
                            icon: "tree.fill",
                            title: "Trees Preserved",
                            value: "0",
                            subtitle: "Help protect our forests",
                            color: .mint
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                // Sample Habits Suggestions
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        Text("Habit Ideas to Get Started")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        SuggestedHabitRow(
                            icon: "bicycle",
                            title: "Bike to Work",
                            category: "Transportation",
                            impact: "~0.22kg CO₂ per km"
                        )
                        
                        SuggestedHabitRow(
                            icon: "bolt.fill",
                            title: "Use LED Bulbs",
                            category: "Energy",
                            impact: "75% energy savings"
                        )
                        
                        SuggestedHabitRow(
                            icon: "leaf.fill",
                            title: "Plant-Based Meals",
                            category: "Food",
                            impact: "~2kg CO₂ saved per meal"
                        )
                        
                        SuggestedHabitRow(
                            icon: "arrow.3.trianglepath",
                            title: "Recycle Paper",
                            category: "Waste",
                            impact: "Saves trees & water"
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                // CTA Button
                Button(action: {
                    showingOnboarding = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Your First Habit")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct OnboardingStepRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ImpactCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SuggestedHabitRow: View {
    let icon: String
    let title: String
    let category: String
    let impact: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                HStack {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(impact)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct WelcomeDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeDashboardView(showingOnboarding: .constant(false))
                .environmentObject(AuthViewModel())
        }
    }
}