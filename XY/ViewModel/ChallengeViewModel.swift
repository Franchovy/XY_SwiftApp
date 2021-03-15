//
//  ChallengeViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 12/03/2021.
//

import UIKit

struct ChallengeViewModel {
    let id: String
    let title: String
    let description: String
    let creator: ProfileModel
    let category: ChallengeModel.Categories
    let level: Int
    let xp: Int
    
    func toModel() -> ChallengeModel {
        return ChallengeModel(
            id: id,
            title: title,
            description: description,
            creatorID: creator.profileId,
            category: category,
            level: level,
            xp: xp
        )
    }
}

