//
//  ContentView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var habitsManager = HabitsManager.shared
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(habitsManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
            
            HabitsView()
                .environmentObject(habitsManager)
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Habits")
                }
            
            GoalsView()
                .environmentObject(habitsManager)
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            ChallengesView()
                .environmentObject(habitsManager)
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Challenges")
                }
            
            ProfileView()
                .environmentObject(habitsManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
}