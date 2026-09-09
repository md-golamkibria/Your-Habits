//
//  User.swift
//  Your Habits
//
//  Created by apple on 22/08/2025.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var name: String
    var profileImageURL: String?
    var profileImageData: Data?
    var points: Int
    var level: Int
    var joinDate: Date
    var badges: [Badge]
    var friends: [UUID] // Friend user IDs
    var totalCO2Saved: Double
    var totalWaterSaved: Double
    var totalTreesPreserved: Double
    
    init(
        id: UUID = UUID(),
        email: String,
        name: String,
        profileImageURL: String? = nil,
        profileImageData: Data? = nil,
        points: Int = 0,
        level: Int = 1,
        joinDate: Date = Date(),
        badges: [Badge] = [],
        friends: [UUID] = [],
        totalCO2Saved: Double = 0.0,
        totalWaterSaved: Double = 0.0,
        totalTreesPreserved: Double = 0.0
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.profileImageData = profileImageData
        self.points = points
        self.level = level
        self.joinDate = joinDate
        self.badges = badges
        self.friends = friends
        self.totalCO2Saved = totalCO2Saved
        self.totalWaterSaved = totalWaterSaved
        self.totalTreesPreserved = totalTreesPreserved
    }
    
    var experienceProgress: Double {
        let pointsForCurrentLevel = level * 100
        let pointsForNextLevel = (level + 1) * 100
        let progressPoints = points - pointsForCurrentLevel
        let totalPointsNeeded = pointsForNextLevel - pointsForCurrentLevel
        return min(1.0, max(0.0, Double(progressPoints) / Double(totalPointsNeeded)))
    }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var iconName: String
    var earnedDate: Date
    var category: BadgeCategory
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        earnedDate: Date = Date(),
        category: BadgeCategory
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.earnedDate = earnedDate
        self.category = category
    }
}

enum BadgeCategory: String, CaseIterable, Codable {
    case environmental = "Environmental"
    case consistency = "Consistency"
    case social = "Social"
    case achievement = "Achievement"
    
    var color: String {
        switch self {
        case .environmental:
            return "green"
        case .consistency:
            return "blue"
        case .social:
            return "purple"
        case .achievement:
            return "orange"
        }
    }
}