//
//  Challenge.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation

struct Challenge: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var requiredHabits: [String] // Habit names that need to be completed
    var rewardPoints: Int
    var isCompleted: Bool
    var participants: [UUID] // User IDs of participants
    var winners: [UUID] // User IDs of winners
    var completedActions: Int // Track progress
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate && !isCompleted
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }
    
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, components.day ?? 1)
    }
    
    // Calculate the total environmental impact based on challenge duration and reward points
    var estimatedTotalImpact: EnvironmentalImpact {
        let dailyImpact = calculateDailyImpactFromPoints()
        let totalDays = Double(durationInDays)
        
        return EnvironmentalImpact(
            co2Saved: dailyImpact.co2Saved * totalDays,
            waterSaved: dailyImpact.waterSaved * totalDays,
            treesPreserved: dailyImpact.treesPreserved * totalDays
        )
    }
    
    // Calculate the actual impact when challenge is completed
    var actualImpact: EnvironmentalImpact {
        if isCompleted {
            return estimatedTotalImpact
        } else {
            // Calculate partial impact based on progress
            let progressRatio = Double(completedActions) / Double(requiredHabits.count)
            let totalImpact = estimatedTotalImpact
            return EnvironmentalImpact(
                co2Saved: totalImpact.co2Saved * progressRatio,
                waterSaved: totalImpact.waterSaved * progressRatio,
                treesPreserved: totalImpact.treesPreserved * progressRatio
            )
        }
    }
    
    private func calculateDailyImpactFromPoints() -> EnvironmentalImpact {
        // Base daily impact calculation based on reward points
        // Higher reward points = higher expected daily impact
        let baseImpactPerDay = Double(rewardPoints) * 0.02 // 0.02 kg CO2 per point per day
        let co2Saved = baseImpactPerDay
        let waterSaved = baseImpactPerDay * 3 // Assume water saving is 3x CO2 impact
        let treesPreserved = co2Saved / 22 // 22 kg CO2 = 1 tree
        
        return EnvironmentalImpact(
            co2Saved: co2Saved,
            waterSaved: waterSaved,
            treesPreserved: treesPreserved
        )
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        requiredHabits: [String],
        rewardPoints: Int,
        isCompleted: Bool = false,
        participants: [UUID] = [],
        winners: [UUID] = [],
        completedActions: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.requiredHabits = requiredHabits
        self.rewardPoints = rewardPoints
        self.isCompleted = isCompleted
        self.participants = participants
        self.winners = winners
        self.completedActions = completedActions
    }
}