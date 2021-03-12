//
//  ChallengeViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit

struct ChallengeVideoViewModel {
    var id: String
    var videoUrl: URL
    var title: String
    var description: String
    var gradient: [UIColor]
    var creator: ProfileModel
    var timeInMinutes: Float
}