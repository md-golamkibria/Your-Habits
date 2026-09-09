//
//  ProfileView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var habitsManager: HabitsManager
    @State private var showingEditProfile = false
    @State private var showingNotificationSettings = false
    @State private var showingAbout = false
    @State private var showingDeleteConfirmation = false

    private var user: User? { auth.currentUser }
    private var impactStats: EnvironmentalImpact {
        EnvironmentalImpact(
            co2Saved: user?.totalCO2Saved ?? 0,
            waterSaved: user?.totalWaterSaved ?? 0,
            treesPreserved: user?.totalTreesPreserved ?? 0
        )
    }
    private var totalHabitsCompleted: Int { habitsManager.completedHabitsThisMonth.count }
    private var currentStreak: Int { habitsManager.currentStreak }
    private var totalPoints: Int { (user?.points ?? 0) + habitsManager.totalPointsEarned }
    private var level: Int { user?.level ?? 1 }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeaderView(user: user, impactStats: impactStats)

                    StatsGridView(
                        totalHabits: totalHabitsCompleted,
                        streak: currentStreak,
                        points: totalPoints,
                        level: level
                    )

                    EnvironmentalImpactView(impact: habitsManager.overallTotalImpact)

                    AccountSettingsView()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and will remove all your data.")
            }
        }
    }
    
    private func deleteAccount() {
        // Clear all user data
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "savedHabits")
        UserDefaults.standard.removeObject(forKey: "savedGoals")
        UserDefaults.standard.removeObject(forKey: "savedChallenges")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        
        // Sign out
        auth.signOut()
    }

    @ViewBuilder
    func AccountSettingsView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Account Settings")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 8) {
                SettingsRow(icon: "person.fill", title: "Edit Profile") {
                    showingEditProfile = true
                }
                
                SettingsRow(icon: "bell.fill", title: "Notifications") {
                    showingNotificationSettings = true
                }
                
                SettingsRow(icon: "info.circle.fill", title: "About") {
                    showingAbout = true
                }
                
                // Delete Account button
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Delete Account")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Logout button
                Button(action: {
                    auth.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Log Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ProfileHeaderView: View {
    let user: User?
    let impactStats: EnvironmentalImpact

    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            if let imageData = user?.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.green)
                    .clipShape(Circle())
            }

            VStack(spacing: 4) {
                Text(user?.name ?? "New User")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(user?.email ?? "no-email@unknown.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 4) {
                Text("Member since")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(user?.joinDate ?? Date(), formatter: shortDateFormatter)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

struct StatsGridView: View {
    let totalHabits: Int
    let streak: Int
    let points: Int
    let level: Int

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatsCard(title: "Habits Done", value: "\(totalHabits)", icon: "checkmark.seal.fill", color: .green)
            StatsCard(title: "Day Streak", value: "\(streak)", icon: "flame.fill", color: .orange)
            StatsCard(title: "Points", value: "\(points)", icon: "star.fill", color: .yellow)
            StatsCard(title: "Level", value: "\(level)", icon: "rosette", color: .blue)
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .clipShape(Circle())

            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct EnvironmentalImpactView: View {
    let impact: EnvironmentalImpact

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Environmental Impact")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                ImpactStatRow(icon: "aqi.mid", title: "CO₂ Saved", value: "\(String(format: "%.1f", impact.co2Saved)) kg", description: "Equivalent to driving fewer miles", color: .green)
                ImpactStatRow(icon: "drop.fill", title: "Water Saved", value: "\(Int(impact.waterSaved)) L", description: "Reduced water consumption", color: .blue)
                ImpactStatRow(icon: "tree.fill", title: "Trees Preserved", value: "\(String(format: "%.1f", impact.treesPreserved))", description: "Based on CO₂ sequestration", color: .mint)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ImpactStatRow: View {
    let icon: String
    let title: String
    let value: String
    let description: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .fontWeight(.medium)
                    Spacer()
                    Text(value)
                        .fontWeight(.semibold)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var name: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let imageData = auth.currentUser?.profileImageData,
                                      let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            
                            PhotosPicker("Change Photo", selection: $selectedPhoto, matching: .images)
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(auth.currentUser?.email ?? "")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                name = auth.currentUser?.name ?? ""
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        profileImage = image
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        guard var user = auth.currentUser else { return }
        
        user.name = name
        
        if let profileImage {
            user.profileImageData = profileImage.jpegData(compressionQuality: 0.8)
        }
        
        auth.updateUser(user)
        dismiss()
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var habitReminders = true
    @State private var goalDeadlines = true
    @State private var challengeUpdates = true
    @State private var weeklyProgress = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("General") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Habit Tracking") {
                    Toggle("Daily Habit Reminders", isOn: $habitReminders)
                        .disabled(!notificationsEnabled)
                    
                    Toggle("Goal Deadline Alerts", isOn: $goalDeadlines)
                        .disabled(!notificationsEnabled)
                    
                    Toggle("Challenge Updates", isOn: $challengeUpdates)
                        .disabled(!notificationsEnabled)
                }
                
                Section("Progress Updates") {
                    Toggle("Weekly Progress Summary", isOn: $weeklyProgress)
                        .disabled(!notificationsEnabled)
                }
                
                Section {
                    Text("Manage your notification preferences to stay motivated and on track with your environmental goals.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        habitReminders = UserDefaults.standard.bool(forKey: "habitReminders")
        goalDeadlines = UserDefaults.standard.bool(forKey: "goalDeadlines")
        challengeUpdates = UserDefaults.standard.bool(forKey: "challengeUpdates")
        weeklyProgress = UserDefaults.standard.bool(forKey: "weeklyProgress")
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(habitReminders, forKey: "habitReminders")
        UserDefaults.standard.set(goalDeadlines, forKey: "goalDeadlines")
        UserDefaults.standard.set(challengeUpdates, forKey: "challengeUpdates")
        UserDefaults.standard.set(weeklyProgress, forKey: "weeklyProgress")
        
        dismiss()
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Your Habits")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Your Habits is an environmental impact tracking app that helps you build sustainable habits, set meaningful goals, and participate in eco-friendly challenges. Track your positive impact on the planet with detailed CO₂, water, and tree preservation calculations.")
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Developer")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("Md. Golam Kibria")
                                    .fontWeight(.semibold)
                                Text("iOS Developer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "leaf.fill", text: "Track environmental impact of your habits")
                            FeatureRow(icon: "target", text: "Set and achieve sustainability goals")
                            FeatureRow(icon: "flag.fill", text: "Join eco-friendly challenges")
                            FeatureRow(icon: "chart.bar.fill", text: "Visualize your progress with detailed analytics")
                            FeatureRow(icon: "bolt.fill", text: "Quick actions for instant impact logging")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AuthViewModel()
        vm.currentUser = User(email: "new.user@example.com", name: "New User")
        vm.isAuthenticated = true

        return ProfileView()
            .environmentObject(vm)
            .environmentObject(HabitsManager.shared)
    }
}