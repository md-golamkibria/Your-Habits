//
//  HabitsView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var habitsManager: HabitsManager
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    StatCard(title: "Today", value: "\(habitsManager.completedHabitsToday.count)", unit: "Completed")
                    StatCard(title: "This Week", value: "\(habitsManager.completedHabitsThisWeek.count)", unit: "Actions")
                    StatCard(title: "CO₂ Saved", value: String(format: "%.1f", habitsManager.totalImpactThisWeek.co2Saved), unit: "kg")
                }
                .padding(.horizontal)
                .padding(.top)

                if habitsManager.habits.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("No habits yet")
                            .font(.headline)
                        Text("Tap the + button to add your first habit.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(habitsManager.categoriesPresent, id: \.self) { category in
                            Section(header:
                                HStack {
                                    Image(systemName: category.iconName)
                                        .foregroundColor(Color(category.color))
                                    Text(category.rawValue)
                                        .fontWeight(.semibold)
                                }
                            ) {
                                ForEach(habitsManager.habitsForCategory(category)) { habit in
                                    HabitRow(habit: habit) {
                                        habitsManager.toggleHabitCompletion(habit)
                                    }
                                    .swipeActions {
                                        Button("Delete") {
                                            habitsManager.deleteHabit(habit)
                                        }
                                        .tint(.red)
                                    }
                                    .onTapGesture {
                                        selectedHabit = habit
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
                    .environmentObject(habitsManager)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                Text(habit.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if habit.isCompleted {
                    HStack(spacing: 8) {
                        if habit.impact.co2Saved > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "leaf.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("\(String(format: "%.1f", habit.impact.co2Saved))kg CO₂")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }

                        if habit.impact.waterSaved > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("\(Int(habit.impact.waterSaved))L H₂O")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }

                        if habit.impact.treesPreserved > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "tree.fill")
                                    .font(.caption)
                                    .foregroundColor(.mint)
                                Text("\(String(format: "%.2f", habit.impact.treesPreserved)) trees")
                                    .font(.caption)
                                    .foregroundColor(.mint)
                            }
                        }
                    }
                    .padding(.top, 2)
                } else {
                    HStack(spacing: 2) {
                        Text("\(habit.value, specifier: "%.1f") \(habit.measurementType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            Button(action: onToggle) {
                if habit.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Habit View

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitsManager: HabitsManager

    @State private var name = ""
    @State private var description = ""
    @State private var category: HabitCategory = .transportation
    @State private var measurementType: MeasurementType = .count
    @State private var value = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }

                Section("Measurement") {
                    Picker("Type", selection: $measurementType) {
                        ForEach(MeasurementType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                    
                    TextField("Value", text: $value)
                        .keyboardType(.decimalPad)
                        .overlay(
                            HStack {
                                Spacer()
                                Text(measurementType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                        )
                }
                
                if !value.isEmpty, let habitValue = Double(value) {
                    Section("Estimated Impact") {
                        let impact = calculateEnvironmentalImpact(
                            category: category,
                            measurementType: measurementType,
                            value: habitValue
                        )
                        
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("CO₂ Saved")
                            Spacer()
                            Text("\(String(format: "%.2f", impact.co2Saved)) kg")
                                .fontWeight(.semibold)
                        }
                        
                        if impact.waterSaved > 0 {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                Text("Water Saved")
                                Spacer()
                                Text("\(Int(impact.waterSaved)) L")
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "tree.fill")
                                .foregroundColor(.mint)
                            Text("Trees Preserved")
                            Spacer()
                            Text("\(String(format: "%.3f", impact.treesPreserved))")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty || value.isEmpty || Double(value) == nil)
                }
            }
        }
    }

    func saveHabit() {
        guard let habitValue = Double(value) else { return }
        
        // Create environmental impact based on habit
        let impact = calculateEnvironmentalImpact(
            category: category,
            measurementType: measurementType,
            value: habitValue
        )
        
        // Create the new habit
        let newHabit = Habit(
            name: name,
            description: description,
            category: category,
            measurementType: measurementType,
            isCompleted: false,
            date: Date(),
            value: habitValue,
            impact: impact
        )
        
        // Add to habits manager
        habitsManager.addHabit(newHabit)
        
        dismiss()
    }
    
    private func calculateEnvironmentalImpact(
        category: HabitCategory,
        measurementType: MeasurementType,
        value: Double
    ) -> EnvironmentalImpact {
        // Simplified impact calculation - in a real app this would be more complex
        switch category {
        case .transportation:
            // Example: biking instead of driving
            let co2Saved = value * 0.2 // kg CO2 per km not driven
            let treesPreserved = co2Saved / 22 // approximate trees needed to offset CO2
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .energy:
            // Example: using renewable energy
            let co2Saved = value * 0.5 // kg CO2 per kWh of clean energy used
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .waste:
            // Example: recycling
            let co2Saved = value * 0.3 // kg CO2 per kg of waste recycled
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        case .water:
            // Example: water conservation
            let co2Saved = value * 0.1 // kg CO2 per liter saved
            let treesPreserved = co2Saved / 22
            let waterSaved = value
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: waterSaved, treesPreserved: treesPreserved)
        case .food:
            // Example: plant-based meals
            let co2Saved = value * 2.0 // kg CO2 per plant-based meal
            let treesPreserved = co2Saved / 22
            let waterSaved = value * 50 // liters saved per meal
            return EnvironmentalImpact(co2Saved: co2Saved, waterSaved: waterSaved, treesPreserved: treesPreserved)
        case .consumption:
            // Example: buying less/reusing
            let co2Saved = value * 0.15
            let treesPreserved = co2Saved / 22
            return EnvironmentalImpact(co2Saved: co2Saved, treesPreserved: treesPreserved)
        }
    }
}

// MARK: - Habit Detail View

struct HabitDetailView: View {
    let habit: Habit

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: habit.category.iconName)
                                .font(.title)
                                .foregroundColor(Color(habit.category.color))
                            Text(habit.name)
                                .font(.title)
                                .fontWeight(.bold)
                        }

                        Text(habit.description)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Status:")
                                .fontWeight(.medium)
                            Text(habit.isCompleted ? "Completed" : "Pending")
                                .foregroundColor(habit.isCompleted ? .green : .orange)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Environmental Impact")
                                .font(.headline)
                            Spacer()
                        }

                        VStack(spacing: 12) {
                            StatRow(icon: "aqi.mid", title: "CO₂ Saved", value: "\(String(format: "%.2f", habit.impact.co2Saved)) kg", color: .green)
                            StatRow(icon: "drop.fill", title: "Water Saved", value: "\(Int(habit.impact.waterSaved)) L", color: .blue)
                            StatRow(icon: "tree.fill", title: "Trees Preserved", value: "\(String(format: "%.3f", habit.impact.treesPreserved))", color: .mint)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("Log Entry")
                                .font(.headline)
                            Spacer()
                        }

                        HStack {
                            Text("Date:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(habit.date, formatter: dateFormatter)")
                        }

                        HStack {
                            Text("Value:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(habit.value, specifier: "%.1f") \(habit.measurementType.rawValue)")
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Habit Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                    }
                }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

struct StatRow: View {
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

struct HabitsView_Previews: PreviewProvider {
    static var previews: some View {
        HabitsView()
            .environmentObject(HabitsManager.shared)
    }
}