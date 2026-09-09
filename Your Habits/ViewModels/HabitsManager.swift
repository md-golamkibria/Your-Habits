//
//  HabitsManager.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class HabitsManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var goals: [Goal] = []
    @Published var challenges: [Challenge] = []
    
    static let shared = HabitsManager()
    
    private init() {
        loadData()
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        updateGoalProgress(from: habit)
        updateChallengeProgress(from: habit)
        saveData()
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveData()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
            habits[index].date = Date() // Update completion date
            updateGoalProgress(from: habits[index])
            updateChallengeProgress(from: habits[index])
            saveData()
        }
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            updateGoalProgress(from: habit)
            updateChallengeProgress(from: habit)
            saveData()
        }
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveData()
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }
    
    private func updateGoalProgress(from habit: Habit) {
        for i in 0..<goals.count {
            if goals[i].category == habit.category && habit.isCompleted && !goals[i].isCompleted {
                goals[i].currentValue += habit.value
                if goals[i].progress >= 1.0 {
                    goals[i].isCompleted = true
                }
            }
        }
    }
    
    // MARK: - Challenge Management
    
    func addChallenge(_ challenge: Challenge) {
        challenges.append(challenge)
        saveData()
    }
    
    func deleteChallenge(_ challenge: Challenge) {
        challenges.removeAll { $0.id == challenge.id }
        saveData()
    }
    
    func updateChallenge(_ challenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index] = challenge
            saveData()
        }
    }
    
    private func updateChallengeProgress(from habit: Habit) {
        for i in 0..<challenges.count {
            if challenges[i].isActive && habit.isCompleted {
                // Check if habit matches any required habits
                let habitMatches = challenges[i].requiredHabits.contains { requiredHabit in
                    habit.name.lowercased().contains(requiredHabit.lowercased()) ||
                    habit.category.rawValue.lowercased().contains(requiredHabit.lowercased())
                }
                
                if habitMatches {
                    challenges[i].completedActions += 1
                    // Mark challenge as completed if all actions are done
                    if challenges[i].completedActions >= challenges[i].requiredHabits.count * 3 { // Require multiple completions
                        challenges[i].isCompleted = true
                    }
                }
            }
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        // Save habits
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "savedHabits")
        }
        
        // Save goals
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "savedGoals")
        }
        
        // Save challenges
        if let encoded = try? JSONEncoder().encode(challenges) {
            UserDefaults.standard.set(encoded, forKey: "savedChallenges")
        }
    }
    
    private func loadData() {
        // Load habits
        if let data = UserDefaults.standard.data(forKey: "savedHabits"),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        }
        
        // Load goals
        if let data = UserDefaults.standard.data(forKey: "savedGoals"),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decodedGoals
        }
        
        // Load challenges
        if let data = UserDefaults.standard.data(forKey: "savedChallenges"),
           let decodedChallenges = try? JSONDecoder().decode([Challenge].self, from: data) {
            challenges = decodedChallenges
        }
    }
    
    // MARK: - Statistics & Calculations
    
    var completedHabitsToday: [Habit] {
        let calendar = Calendar.current
        return habits.filter { $0.isCompleted && calendar.isDateInToday($0.date) }
    }
    
    var completedHabitsThisWeek: [Habit] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return habits.filter { $0.isCompleted && $0.date >= startOfWeek }
    }
    
    var completedHabitsThisMonth: [Habit] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        return habits.filter { $0.isCompleted && $0.date >= startOfMonth }
    }
    
    var totalImpactToday: EnvironmentalImpact {
        let todayHabits = completedHabitsToday
        return calculateTotalImpact(from: todayHabits)
    }
    
    var totalImpactThisWeek: EnvironmentalImpact {
        let weekHabits = completedHabitsThisWeek
        return calculateTotalImpact(from: weekHabits)
    }
    
    var totalImpactThisMonth: EnvironmentalImpact {
        let monthHabits = completedHabitsThisMonth
        return calculateTotalImpact(from: monthHabits)
    }
    
    var totalImpactFromGoals: EnvironmentalImpact {
        let completedGoals = goals.filter { $0.isCompleted }
        var totalCO2: Double = 0
        var totalWater: Double = 0
        var totalTrees: Double = 0
        
        for goal in completedGoals {
            let impact = calculateGoalImpact(goal)
            totalCO2 += impact.co2Saved
            totalWater += impact.waterSaved
            totalTrees += impact.treesPreserved
        }
        
        return EnvironmentalImpact(co2Saved: totalCO2, waterSaved: totalWater, treesPreserved: totalTrees)
    }
    
    var totalImpactFromChallenges: EnvironmentalImpact {
        let completedChallenges = challenges.filter { $0.isCompleted }
        var totalCO2: Double = 0
        var totalWater: Double = 0
        var totalTrees: Double = 0
        
        for challenge in completedChallenges {
            let impact = calculateChallengeImpact(challenge)
            totalCO2 += impact.co2Saved
            totalWater += impact.waterSaved
            totalTrees += impact.treesPreserved
        }
        
        return EnvironmentalImpact(co2Saved: totalCO2, waterSaved: totalWater, treesPreserved: totalTrees)
    }
    
    var overallTotalImpact: EnvironmentalImpact {
        let habitImpact = totalImpactThisWeek
        let goalImpact = totalImpactFromGoals
        let challengeImpact = totalImpactFromChallenges
        
        return EnvironmentalImpact(
            co2Saved: habitImpact.co2Saved + goalImpact.co2Saved + challengeImpact.co2Saved,
            waterSaved: habitImpact.waterSaved + goalImpact.waterSaved + challengeImpact.waterSaved,
            treesPreserved: habitImpact.treesPreserved + goalImpact.treesPreserved + challengeImpact.treesPreserved
        )
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let dayHabits = habits.filter { habit in
                habit.isCompleted && calendar.isDate(habit.date, inSameDayAs: currentDate)
            }
            
            if dayHabits.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    var completionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let completedCount = habits.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(habits.count)
    }
    
    private func calculateTotalImpact(from habits: [Habit]) -> EnvironmentalImpact {
        let totalCO2 = habits.reduce(0) { $0 + $1.impact.co2Saved }
        let totalWater = habits.reduce(0) { $0 + $1.impact.waterSaved }
        let totalTrees = habits.reduce(0) { $0 + $1.impact.treesPreserved }
        
        return EnvironmentalImpact(
            co2Saved: totalCO2,
            waterSaved: totalWater,
            treesPreserved: totalTrees
        )
    }
    
    func calculateGoalImpact(_ goal: Goal) -> EnvironmentalImpact {
        let baseValue = goal.currentValue
        let durationMultiplier = max(1.0, Double(goal.timeRemaining) / 30.0) // Longer goals have more impact
        let categoryMultiplier = getCategoryMultiplier(for: goal.category)
        
        switch goal.category {
        case .transportation:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .energy:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .water:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier * 0.1
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: baseValue * durationMultiplier, treesPreserved: treesPreserved)
        case .food:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier
            let treesPreserved = co2Saved / 22
            let waterSaved = baseValue * 50 * durationMultiplier
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: waterSaved, treesPreserved: treesPreserved)
        case .waste:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .consumption:
            let co2Saved = baseValue * categoryMultiplier * durationMultiplier
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        }
    }
    
    func calculateChallengeImpact(_ challenge: Challenge) -> EnvironmentalImpact {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: challenge.startDate, to: challenge.endDate).day ?? 1
        let durationMultiplier = max(1.0, Double(days) / 7.0) // Longer challenges have more impact
        let pointsMultiplier = Double(challenge.rewardPoints) / 100.0 // Higher rewards = more impact
        let habitsMultiplier = Double(challenge.requiredHabits.count) / 3.0 // More required habits = more impact
        
        let baseImpact = 1.0 * durationMultiplier * pointsMultiplier * habitsMultiplier
        
        return EnvironmentalImpact(
            co2Saved: baseImpact * 2.0, // 2kg CO2 base
            waterSaved: baseImpact * 100.0, // 100L water base
            treesPreserved: (baseImpact * 2.0) / 22 // Trees based on CO2
        )
    }
    
    private func getCategoryMultiplier(for category: HabitCategory) -> Double {
        switch category {
        case .transportation: return 0.3 // Higher impact for transportation
        case .energy: return 0.7 // Very high impact for energy savings
        case .water: return 0.1 // Lower direct CO2 impact
        case .food: return 2.5 // High impact for dietary changes
        case .waste: return 0.4 // Moderate impact for waste reduction
        case .consumption: return 0.2 // Lower impact for consumption changes
        }
    }
    
    // MARK: - Categories & Statistics
    
    var categoriesPresent: [HabitCategory] {
        Array(Set(habits.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
    }
    
    func habitsForCategory(_ category: HabitCategory) -> [Habit] {
        return habits.filter { $0.category == category }
    }
    
    func completedHabitsForCategory(_ category: HabitCategory) -> [Habit] {
        return habits.filter { $0.category == category && $0.isCompleted }
    }
    
    // MARK: - Goal Statistics
    
    var activeGoals: [Goal] {
        return goals.filter { !$0.isCompleted && $0.timeRemaining > 0 }
    }
    
    var completedGoals: [Goal] {
        return goals.filter { $0.isCompleted }
    }
    
    var averageGoalProgress: Double {
        guard !goals.isEmpty else { return 0 }
        let sum = goals.reduce(0.0) { $0 + $1.progress }
        return sum / Double(goals.count)
    }
    
    // MARK: - Challenge Statistics
    
    var activeChallenges: [Challenge] {
        return challenges.filter { $0.isActive }
    }
    
    var completedChallenges: [Challenge] {
        return challenges.filter { $0.isCompleted }
    }
    
    var totalPointsEarned: Int {
        return completedChallenges.reduce(0) { $0 + $1.rewardPoints }
    }
}