//
//  EPACalculationService.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation

class EPACalculationService {
    // Based on EPA Greenhouse Gas Equivalencies Calculator
    // https://www.epa.gov/energy/greenhouse-gas-equivalencies-calculator
    
    // MARK: - Constants (EPA-based values)
    
    /// CO2 saved per kilometer biked instead of driving (kg CO2/km)
    static let co2SavedPerKilometerBike = 0.22 // Approximate value
    
    /// CO2 saved per minute of LED bulb usage instead of incandescent (kg CO2/minute)
    static let co2SavedPerMinuteLED = 0.0025 // Approximate value
    
    /// CO2 saved per kilogram of recycling (kg CO2/kg)
    static let co2SavedPerKilogramRecycling = 1.5 // Approximate value
    
    /// Water saved per minute of shower reduction (liters/minute)
    static let waterSavedPerMinuteShower = 10.0 // Standard showerhead
    
    /// Trees preserved per kg of CO2 saved (trees/kg CO2)
    static let treesPreservedPerKgCO2 = 0.0007 // Based on tree sequestration rates
    
    // MARK: - Calculation Methods
    
    /// Calculate environmental impact for biking instead of driving
    /// - Parameter kilometers: Distance biked
    /// - Returns: EnvironmentalImpact struct with calculated values
    static func calculateBikeImpact(kilometers: Double) -> EnvironmentalImpact {
        let co2Saved = kilometers * co2SavedPerKilometerBike
        let treesPreserved = co2Saved * treesPreservedPerKgCO2
        
        return EnvironmentalImpact(
            co2Saved: co2Saved,
            waterSaved: 0, // Biking doesn't save water directly
            treesPreserved: treesPreserved
        )
    }
    
    /// Calculate environmental impact for recycling
    /// - Parameter kilograms: Weight of recycled materials
    /// - Returns: EnvironmentalImpact struct with calculated values
    static func calculateRecyclingImpact(kilograms: Double) -> EnvironmentalImpact {
        let co2Saved = kilograms * co2SavedPerKilogramRecycling
        let treesPreserved = co2Saved * treesPreservedPerKgCO2
        
        return EnvironmentalImpact(
            co2Saved: co2Saved,
            waterSaved: 0, // Recycling doesn't save water directly in this model
            treesPreserved: treesPreserved
        )
    }
    
    /// Calculate environmental impact for using LED bulbs
    /// - Parameter minutes: Minutes of LED bulb usage
    /// - Returns: EnvironmentalImpact struct with calculated values
    static func calculateLEDImpact(minutes: Double) -> EnvironmentalImpact {
        let co2Saved = minutes * co2SavedPerMinuteLED
        let treesPreserved = co2Saved * treesPreservedPerKgCO2
        
        return EnvironmentalImpact(
            co2Saved: co2Saved,
            waterSaved: 0, // LED usage doesn't save water directly
            treesPreserved: treesPreserved
        )
    }
    
    /// Calculate environmental impact for reducing shower time
    /// - Parameter minutes: Minutes of reduced shower time
    /// - Returns: EnvironmentalImpact struct with calculated values
    static func calculateShowerImpact(minutes: Double) -> EnvironmentalImpact {
        let waterSaved = minutes * waterSavedPerMinuteShower
        // Water saved indirectly reduces energy for water heating
        let co2Saved = waterSaved * 0.02 // Approximate heating factor
        let treesPreserved = co2Saved * treesPreservedPerKgCO2
        
        return EnvironmentalImpact(
            co2Saved: co2Saved,
            waterSaved: waterSaved,
            treesPreserved: treesPreserved
        )
    }
    
    /// Calculate environmental impact for generic habit
    /// - Parameters:
    ///   - habitName: Name of the habit
    ///   - value: Value of the habit (e.g., distance, time, weight)
    ///   - measurementType: Type of measurement
    /// - Returns: EnvironmentalImpact struct with calculated values
    static func calculateImpact(for habitName: String, value: Double, measurementType: MeasurementType) -> EnvironmentalImpact {
        // This would be more sophisticated in a real app with a database of habits
        switch habitName.lowercased() {
        case let name where name.contains("bike") || name.contains("cycle"):
            if measurementType == .kilometers {
                return calculateBikeImpact(kilometers: value)
            }
        case let name where name.contains("recycl"):
            if measurementType == .kilograms {
                return calculateRecyclingImpact(kilograms: value)
            }
        case let name where name.contains("led") || name.contains("light"):
            if measurementType == .minutes || measurementType == .hours {
                let minutes = measurementType == .hours ? value * 60 : value
                return calculateLEDImpact(minutes: minutes)
            }
        case let name where name.contains("shower") || name.contains("bath"):
            if measurementType == .minutes || measurementType == .hours {
                let minutes = measurementType == .hours ? value * 60 : value
                return calculateShowerImpact(minutes: minutes)
            }
        default:
            break
        }
        
        // Default minimal impact if habit is not recognized
        return EnvironmentalImpact()
    }
}