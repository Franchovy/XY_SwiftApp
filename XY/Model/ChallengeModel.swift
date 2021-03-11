//
//  ChallengeModel.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import Foundation

struct ChallengeModel {
    let id: String
    let title: String
    let description: String
    let creatorID: String
    let level: Int
    let xp: Int
    
    
    static func getDemoChallenges() -> [ChallengeModel] {
        return [
            ChallengeModel(id: "", title: "RunToTheTop", description: "Run to the top of a mountain", creatorID: "", level: 0, xp: 0),
            ChallengeModel(id: "", title: "ColorTheFace", description: "Draw on the face of your best friend", creatorID: "", level: 0, xp: 0),
            ChallengeModel(id: "", title: "HelpGrandma", description: "Help a grandma cross the road", creatorID: "", level: 0, xp: 0),
            ChallengeModel(id: "", title: "EatABurger", description: "Eat a hamburger in less than 1 minute", creatorID: "", level: 0, xp: 0),
            ChallengeModel(id: "", title: "CloseThePhone", description: "Close your phone and upload the video of it", creatorID: "", level: 0, xp: 0),
        ]
    }
}

