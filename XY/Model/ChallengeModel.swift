//
//  ChallengeModel.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit

struct ChallengeModel {
    let id: String
    let title: String
    let description: String
    let creatorID: String
    let category: Categories
    let level: Int
    let xp: Int
    
    enum Categories : String, CaseIterable {
        case xyChallenges
        case karmaChallenges
        case playerChallenges
        
        func getGradient() -> [UIColor] {
            switch self {
            case .xyChallenges:
                return [UIColor(0xFF0062), UIColor(0x0C98F6)]
            case .karmaChallenges:
                return [UIColor(0x00FF0D), UIColor(0x00FFFC), UIColor(0x00FF6A)]
            case .playerChallenges:
                return [.white, UIColor(named: "XYWhite")!]
            }
        }
        
        func getGradientAdaptedToLightMode() -> [UIColor] {
            switch self {
            case .xyChallenges:
                return [UIColor(0xFF0062), UIColor(0x0C98F6)]
            case .karmaChallenges:
                return [UIColor(0x00FF0D), UIColor(0x00FFFC), UIColor(0x00FF6A)]
            case .playerChallenges:
                return [UIColor(named: "tintColor")!, UIColor(named: "XYTint")!]
            }
        }
        
        func toString() -> String {
            switch self {
            case .xyChallenges:
                return "XY's Challenges"
            case .karmaChallenges:
                return "Karma Challenges"
            case .playerChallenges:
                return "Players' Challenges"
            }
        }
        
        func getDescription() -> String {
            switch self {
            case .xyChallenges:
                return "A series of challenges created by the founders of XY."
            case .karmaChallenges:
                return "Do something good for the world. Increase your karma."
            case .playerChallenges:
                return ""
            }
        }
    }
}

