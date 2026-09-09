//
//  GoalsView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var habitsManager: HabitsManager
    @State private var showingAddGoal = false

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    StatCard(title: "Active", value: "\(habitsManager.activeGoals.count)", unit: "Goals")
                    StatCard(title: "Completed", value: "\(habitsManager.completedGoals.count)", unit: "This Month")
                    StatCard(title: "Avg. Progress", value: "\(Int(habitsManager.averageGoalProgress * 100))", unit: "%")
                }
                .padding(.horizontal)
                .padding(.top)

                if habitsManager.goals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("No goals yet")
                            .font(.headline)
                        Text("Tap the + button to create your first goal.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(habitsManager.goals) { goal in
                            GoalRow(goal: goal)
                                .swipeActions {
                                    Button("Delete") {
                                        habitsManager.deleteGoal(goal)
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .environmentObject(habitsManager)
            }
        }
    }
}

struct GoalRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.category.iconName)
                    .font(.title3)
                    .foregroundColor(Color(goal.category.color))

                VStack(alignment: .leading) {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("\(Int(goal.currentValue))/\(Int(goal.targetValue)) \(goal.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(goal.progress), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(goal.timeRemaining) days left")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if goal.isCompleted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("In Progress")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Show estimated vs actual impact
            VStack(alignment: .leading, spacing: 4) {
                Text("Environmental Impact:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if goal.isCompleted {
                    let impact = goal.actualImpact
                    HStack(spacing: 12) {
                        HStack(spacing: 2) {
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(String(format: "%.1f", impact.co2Saved))kg CO₂")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        if impact.waterSaved > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("\(Int(impact.waterSaved))L H₂O")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "tree.fill")
                                .font(.caption)
                                .foregroundColor(.mint)
                            Text("\(String(format: "%.2f", impact.treesPreserved)) trees")
                                .font(.caption)
                                .foregroundColor(.mint)
                        }
                    }
                } else {
                    // Show current progress impact vs estimated total
                    let currentImpact = goal.actualImpact
                    let estimatedImpact = goal.estimatedTotalImpact
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 12) {
                            HStack(spacing: 2) {
                                Image(systemName: "leaf.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("\(String(format: "%.1f", currentImpact.co2Saved))/\(String(format: "%.1f", estimatedImpact.co2Saved))kg CO₂")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if estimatedImpact.waterSaved > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("\(Int(currentImpact.waterSaved))/\(Int(estimatedImpact.waterSaved))L H₂O")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        Text("Duration: \(goal.durationInDays) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitsManager: HabitsManager

    @State private var title = ""
    @State private var description = ""
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var category: HabitCategory = .transportation
    @State private var durationDays = 30

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Target") {
                    TextField("Target Value", text: $targetValue)
                        .keyboardType(.decimalPad)
                    TextField("Unit (e.g. km, hours)", text: $unit)
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

                Section("Duration") {
                    Picker("Duration", selection: $durationDays) {
                        Text("7 days").tag(7)
                        Text("14 days").tag(14)
                        Text("30 days").tag(30)
                        Text("60 days").tag(60)
                        Text("90 days").tag(90)
                    }
                    .pickerStyle(.segmented)
                }
                
                if !targetValue.isEmpty, let target = Double(targetValue) {
                    Section("Estimated Total Impact (\(durationDays) days)") {
                        let tempGoal = Goal(
                            title: title,
                            description: description,
                            targetValue: target,
                            unit: unit,
                            endDate: Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date(),
                            category: category
                        )
                        let impact = tempGoal.estimatedTotalImpact
                        
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
                        
                        Text("Based on \(String(format: "%.1f", target)) \(unit) over \(durationDays) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || targetValue.isEmpty || unit.isEmpty)
                }
            }
        }
    }

    func saveGoal() {
        guard let target = Double(targetValue) else { return }
        
        let endDate = Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date()
        
        let newGoal = Goal(
            title: title,
            description: description,
            targetValue: target,
            unit: unit,
            endDate: endDate,
            category: category
        )
        
        habitsManager.addGoal(newGoal)
        dismiss()
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            .environmentObject(HabitsManager.shared)
    }
}