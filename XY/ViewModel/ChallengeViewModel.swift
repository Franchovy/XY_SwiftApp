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
    let gradient: [UIColor]
    let level: Int
    let xp: Int
}

