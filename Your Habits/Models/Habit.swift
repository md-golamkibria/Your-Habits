//
//  Habit.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var category: HabitCategory
    var measurementType: MeasurementType
    var isCompleted: Bool
    var date: Date
    var value: Double // Amount for measurement (e.g., 5 km biked, 30 mins walked)
    var impact: EnvironmentalImpact
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        category: HabitCategory,
        measurementType: MeasurementType,
        isCompleted: Bool = false,
        date: Date = Date(),
        value: Double = 0.0,
        impact: EnvironmentalImpact = EnvironmentalImpact()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.measurementType = measurementType
        self.isCompleted = isCompleted
        self.date = date
        self.value = value
        self.impact = impact
    }
}

enum HabitCategory: String, CaseIterable, Codable {
    case transportation = "Transportation"
    case energy = "Energy"
    case waste = "Waste"
    case water = "Water"
    case food = "Food"
    case consumption = "Consumption"
    
    var iconName: String {
        switch self {
        case .transportation:
            return "bicycle"
        case .energy:
            return "bolt"
        case .waste:
            return "trash"
        case .water:
            return "drop"
        case .food:
            return "leaf"
        case .consumption:
            return "cart"
        }
    }
    
    var color: String {
        switch self {
        case .transportation:
            return "blue"
        case .energy:
            return "yellow"
        case .waste:
            return "gray"
        case .water:
            return "teal"
        case .food:
            return "green"
        case .consumption:
            return "orange"
        }
    }
}

enum MeasurementType: String, CaseIterable, Codable {
    case kilometers = "Kilometers"
    case minutes = "Minutes"
    case kilograms = "Kilograms"
    case liters = "Liters"
    case count = "Count"
    case hours = "Hours"
}

struct EnvironmentalImpact: Codable {
    var co2Saved: Double // in kg
    var waterSaved: Double // in liters
    var treesPreserved: Double // in count
    
    init(co2Saved: Double = 0.0, waterSaved: Double = 0.0, treesPreserved: Double = 0.0) {
        self.co2Saved = co2Saved
        self.waterSaved = waterSaved
        self.treesPreserved = treesPreserved
    }
}