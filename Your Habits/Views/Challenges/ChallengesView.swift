//
//  ChallengesView.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var habitsManager: HabitsManager
    @State private var showingJoinChallenge = false

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    StatCard(title: "Active", value: "\(habitsManager.activeChallenges.count)", unit: "Challenges")
                    StatCard(title: "Completed", value: "\(habitsManager.completedChallenges.count)", unit: "This Month")
                    StatCard(title: "Points", value: "\(habitsManager.totalPointsEarned)", unit: "Earned")
                }
                .padding(.horizontal)
                .padding(.top)

                if habitsManager.challenges.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "flag")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("No challenges yet")
                            .font(.headline)
                        Text("Tap the + button to join or create a challenge.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(habitsManager.challenges) { challenge in
                            ChallengeRow(challenge: challenge)
                                .swipeActions {
                                    Button("Leave") {
                                        habitsManager.deleteChallenge(challenge)
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingJoinChallenge = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingJoinChallenge) {
                JoinChallengeView()
                    .environmentObject(habitsManager)
            }
        }
    }
}

struct ChallengeRow: View {
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill")
                    .font(.title2)
                    .foregroundColor(.orange)

                VStack(alignment: .leading) {
                    Text(challenge.title)
                        .font(.headline)
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if challenge.isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else if challenge.isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    Text("Upcoming")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text("Ends in \(challenge.daysRemaining) days")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(challenge.rewardPoints) pts")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Required Actions:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                FlowLayout(data: challenge.requiredHabits, spacing: 6, lineSpacing: 6) { habit in
                    Text(habit)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Show estimated impact when challenge is completed
            if challenge.isCompleted {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Environmental Impact:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    let impact = calculateChallengeImpact(challenge)
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
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func calculateChallengeImpact(_ challenge: Challenge) -> EnvironmentalImpact {
        let baseImpact = Double(challenge.rewardPoints) * 0.1
        return EnvironmentalImpact(
            co2Saved: baseImpact,
            waterSaved: baseImpact * 5,
            treesPreserved: baseImpact / 22
        )
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat = 8, lineSpacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(layoutRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { element in
                        content(element)
                    }
                }
            }
        }
    }

    private func layoutRows() -> [[Data.Element]] {
        return [Array(data)]
    }
}

// MARK: - Join Challenge View

struct JoinChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitsManager: HabitsManager

    @State private var title = ""
    @State private var description = ""
    @State private var requiredHabits = ""
    @State private var rewardPoints = ""
    @State private var durationDays = 7

    var body: some View {
        NavigationView {
            Form {
                Section("Challenge Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Requirements") {
                    TextField("Required Habits (comma separated)", text: $requiredHabits)
                    TextField("Reward Points", text: $rewardPoints)
                        .keyboardType(.numberPad)
                }

                Section("Duration") {
                    Picker("Duration", selection: $durationDays) {
                        Text("3 days").tag(3)
                        Text("7 days").tag(7)
                        Text("14 days").tag(14)
                        Text("30 days").tag(30)
                    }
                    .pickerStyle(.segmented)
                }
                
                if !rewardPoints.isEmpty, let points = Int(rewardPoints) {
                    Section("Estimated Impact When Completed") {
                        let impact = calculateEstimatedChallengeImpact(points: points)
                        
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("CO₂ Saved")
                            Spacer()
                            Text("\(String(format: "%.2f", impact.co2Saved)) kg")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("Water Saved")
                            Spacer()
                            Text("\(Int(impact.waterSaved)) L")
                                .fontWeight(.semibold)
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
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createChallenge()
                    }
                    .disabled(title.isEmpty || requiredHabits.isEmpty || rewardPoints.isEmpty)
                }
            }
        }
    }

    func createChallenge() {
        guard let points = Int(rewardPoints) else { return }
        
        let habits = requiredHabits.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let endDate = Calendar.current.date(byAdding: .day, value: durationDays, to: Date()) ?? Date()
        
        let newChallenge = Challenge(
            title: title,
            description: description,
            startDate: Date(),
            endDate: endDate,
            requiredHabits: habits,
            rewardPoints: points
        )
        
        habitsManager.addChallenge(newChallenge)
        dismiss()
    }
    
    private func calculateEstimatedChallengeImpact(points: Int) -> EnvironmentalImpact {
        let baseImpact = Double(points) * 0.1
        return EnvironmentalImpact(
            co2Saved: baseImpact,
            waterSaved: baseImpact * 5,
            treesPreserved: baseImpact / 22
        )
    }
}

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
            .environmentObject(HabitsManager.shared)
    }
}