//
//  DashboardView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var habitsManager: HabitsManager

    private var user: User? { auth.currentUser }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ImpactSummaryView(impact: habitsManager.overallTotalImpact, period: "Overall Impact")
                    
                    TodayImpactView(impact: habitsManager.totalImpactToday)
                    
                    StreakAndCompletionView(
                        streakCount: habitsManager.currentStreak, 
                        completionRate: habitsManager.completionRate
                    )
                    
                    ProgressChartsView(
                        todayCount: habitsManager.completedHabitsToday.count,
                        weekCount: habitsManager.completedHabitsThisWeek.count,
                        monthCount: habitsManager.completedHabitsThisMonth.count
                    )
                    
                    RecentAchievementsView(badges: user?.badges ?? [])
                    
                    QuickActionsView(habitsManager: habitsManager)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                // Refresh data if needed
            }
        }
    }
}

// MARK: - Subviews

struct ImpactSummaryView: View {
    let impact: EnvironmentalImpact
    let period: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text(period)
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                ImpactRow(icon: "aqi.mid", title: "CO₂ Saved", value: "\(String(format: "%.1f", impact.co2Saved)) kg", color: .green)
                ImpactRow(icon: "drop.fill", title: "Water Saved", value: "\(Int(impact.waterSaved)) L", color: .blue)
                ImpactRow(icon: "tree.fill", title: "Trees Preserved", value: "\(String(format: "%.2f", impact.treesPreserved))", color: .mint)
            }

            if impact.co2Saved == 0 && impact.waterSaved == 0 && impact.treesPreserved == 0 {
                Text("No impact logged yet. Start by adding and completing habits.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Show equivalent calculations
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equivalent to:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    if impact.co2Saved > 0 {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("Not driving \(String(format: "%.1f", impact.co2Saved * 5)) km")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if impact.waterSaved > 0 {
                        HStack {
                            Image(systemName: "shower.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(Int(impact.waterSaved / 60)) fewer shower minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if impact.treesPreserved > 0 {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Protecting \(String(format: "%.0f", impact.treesPreserved * 1000)) seedlings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct TodayImpactView: View {
    let impact: EnvironmentalImpact

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Today's Impact")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                VStack {
                    Text("\(String(format: "%.1f", impact.co2Saved))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("kg CO₂")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(Int(impact.waterSaved))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("L H₂O")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(String(format: "%.3f", impact.treesPreserved))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.mint)
                    Text("Trees")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ImpactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct StreakAndCompletionView: View {
    let streakCount: Int
    let completionRate: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Your Progress")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 30) {
                VStack {
                    Text("\(streakCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    Text("\(Int(completionRate * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Completion")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if streakCount == 0 && completionRate == 0 {
                Text("No progress yet. Complete a habit today to start your streak!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if streakCount > 0 {
                Text("Great job! Keep up your \(streakCount)-day streak! 🔥")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ProgressChartsView: View {
    let todayCount: Int
    let weekCount: Int
    let monthCount: Int
    
    private var hasData: Bool { todayCount > 0 || weekCount > 0 || monthCount > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Activity Overview")
                    .font(.headline)
                Spacer()
            }

            if hasData {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Today")
                            .frame(width: 60, alignment: .leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: min(1.0, Double(todayCount) / 5.0), color: .green)
                        
                        Text("\(todayCount)")
                            .frame(width: 30)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("This Week")
                            .frame(width: 60, alignment: .leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: min(1.0, Double(weekCount) / 20.0), color: .blue)
                        
                        Text("\(weekCount)")
                            .frame(width: 30)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("This Month")
                            .frame(width: 60, alignment: .leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ProgressBar(value: min(1.0, Double(monthCount) / 80.0), color: .purple)
                        
                        Text("\(monthCount)")
                            .frame(width: 30)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No activity yet.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Complete habits to see your progress charts here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct ProgressBar: View {
    let value: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(color.opacity(0.3))
                .overlay(
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * max(0, min(1, value)))
                    , alignment: .leading
                )
        }
        .frame(height: 8)
        .cornerRadius(4)
    }
}

struct RecentAchievementsView: View {
    let badges: [Badge]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "medal.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("Recent Achievements")
                    .font(.headline)
                Spacer()
            }

            if badges.isEmpty {
                Text("No achievements yet. Earn badges by completing habits and challenges.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(badges.prefix(3)) { badge in
                        AchievementRow(icon: badge.iconName, title: badge.name, description: badge.description)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }
}

struct QuickActionsView: View {
    let habitsManager: HabitsManager
    @State private var showingQuickAction = false
    @State private var selectedAction: QuickActionType?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Quick Actions")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "bicycle",
                    title: "Log Bike Ride",
                    color: .green
                ) {
                    selectedAction = .bikeRide
                    showingQuickAction = true
                }
                
                QuickActionButton(
                    icon: "leaf.fill",
                    title: "Log Recycling",
                    color: .gray
                ) {
                    selectedAction = .recycling
                    showingQuickAction = true
                }
                
                QuickActionButton(
                    icon: "drop.fill",
                    title: "Save Water",
                    color: .blue
                ) {
                    selectedAction = .waterSaving
                    showingQuickAction = true
                }
                
                QuickActionButton(
                    icon: "lightbulb.fill",
                    title: "Energy Save",
                    color: .yellow
                ) {
                    selectedAction = .energySaving
                    showingQuickAction = true
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .sheet(isPresented: $showingQuickAction) {
            if let action = selectedAction {
                QuickActionView(actionType: action, habitsManager: habitsManager)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(color)
        .cornerRadius(12)
    }
}

enum QuickActionType {
    case bikeRide, recycling, waterSaving, energySaving
    
    var category: HabitCategory {
        switch self {
        case .bikeRide: return .transportation
        case .recycling: return .waste
        case .waterSaving: return .water
        case .energySaving: return .energy
        }
    }
    
    var title: String {
        switch self {
        case .bikeRide: return "Bike Ride"
        case .recycling: return "Recycling"
        case .waterSaving: return "Water Saving"
        case .energySaving: return "Energy Saving"
        }
    }
    
    var measurementType: MeasurementType {
        switch self {
        case .bikeRide: return .kilometers
        case .recycling: return .kilograms
        case .waterSaving: return .liters
        case .energySaving: return .hours
        }
    }
}

struct QuickActionView: View {
    @Environment(\.dismiss) var dismiss
    let actionType: QuickActionType
    let habitsManager: HabitsManager
    
    @State private var value = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: actionType.category.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(Color(actionType.category.color))
                    
                    Text("Quick \(actionType.title)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Log your \(actionType.title.lowercased()) activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    TextField("Enter value", text: $value)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            HStack {
                                Spacer()
                                Text(actionType.measurementType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 12)
                            }
                        )
                    
                    if !value.isEmpty, let habitValue = Double(value) {
                        let impact = calculateQuickActionImpact(habitValue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Impact Preview:")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("CO₂ Saved: \(String(format: "%.2f", impact.co2Saved)) kg")
                            }
                            
                            if impact.waterSaved > 0 {
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(.blue)
                                    Text("Water Saved: \(Int(impact.waterSaved)) L")
                                }
                            }
                            
                            HStack {
                                Image(systemName: "tree.fill")
                                    .foregroundColor(.mint)
                                Text("Trees: \(String(format: "%.3f", impact.treesPreserved))")
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                Button("Log Activity") {
                    logQuickAction()
                }
                .disabled(value.isEmpty || Double(value) == nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background(value.isEmpty || Double(value) == nil ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Quick Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func logQuickAction() {
        guard let habitValue = Double(value) else { return }
        
        let impact = calculateQuickActionImpact(habitValue)
        
        let quickHabit = Habit(
            name: "Quick \(actionType.title)",
            description: "Quick action logged from dashboard",
            category: actionType.category,
            measurementType: actionType.measurementType,
            isCompleted: true, // Quick actions are automatically completed
            date: Date(),
            value: habitValue,
            impact: impact
        )
        
        habitsManager.addHabit(quickHabit)
        dismiss()
    }
    
    private func calculateQuickActionImpact(_ value: Double) -> EnvironmentalImpact {
        switch actionType {
        case .bikeRide:
            let co2Saved = value * 0.2
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .recycling:
            let co2Saved = value * 0.3
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .waterSaving:
            let co2Saved = value * 0.1
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: value, treesPreserved: treesPreserved)
        case .energySaving:
            let co2Saved = value * 0.5
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AuthViewModel()
        vm.currentUser = User(email: "new.user@example.com", name: "New User")
        
        return DashboardView()
            .environmentObject(vm)
            .environmentObject(HabitsManager.shared)
    }
}