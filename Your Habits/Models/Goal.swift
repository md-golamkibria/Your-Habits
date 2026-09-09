//
//  Goal.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var category: HabitCategory
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var timeRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }
    
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, components.day ?? 1)
    }
    
    // Calculate the total environmental impact based on target value and duration
    var estimatedTotalImpact: EnvironmentalImpact {
        let dailyImpact = calculateDailyUnitImpact()
        let totalValue = targetValue // Total target value over duration
        
        return EnvironmentalImpact(
            co2Saved: dailyImpact.co2Saved * totalValue,
            waterSaved: dailyImpact.waterSaved * totalValue,
            treesPreserved: dailyImpact.treesPreserved * totalValue
        )
    }
    
    // Calculate the actual impact based on current progress
    var actualImpact: EnvironmentalImpact {
        let dailyImpact = calculateDailyUnitImpact()
        let completedValue = currentValue
        
        return EnvironmentalImpact(
            co2Saved: dailyImpact.co2Saved * completedValue,
            waterSaved: dailyImpact.waterSaved * completedValue,
            treesPreserved: dailyImpact.treesPreserved * completedValue
        )
    }
    
    private func calculateDailyUnitImpact() -> EnvironmentalImpact {
        let unitValue = 1.0 // Impact per 1 unit (1 km, 1 hour, etc.)
        
        switch category {
        case .transportation:
            // 1 km biking saves ~0.2 kg CO2
            let co2Saved = unitValue * 0.2
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .energy:
            // 1 hour of energy saving saves ~0.5 kg CO2
            let co2Saved = unitValue * 0.5
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .water:
            // 1 liter of water saved saves ~0.1 kg CO2
            let co2Saved = unitValue * 0.1
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: unitValue, treesPreserved: treesPreserved)
        case .waste:
            // 1 kg of waste reduced saves ~0.3 kg CO2
            let co2Saved = unitValue * 0.3
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .food:
            // 1 unit of sustainable food choice saves ~0.25 kg CO2
            let co2Saved = unitValue * 0.25
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .consumption:
            // 1 unit of reduced consumption saves ~0.15 kg CO2
            let co2Saved = unitValue * 0.15
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        targetValue: Double,
        currentValue: Double = 0.0,
        unit: String,
        startDate: Date = Date(),
        endDate: Date,
        isCompleted: Bool = false,
        category: HabitCategory
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.category = category
    }
}