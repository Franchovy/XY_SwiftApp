//
//  RankingModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import Foundation

struct RankingModel {
    let name: String
    let ranking:
        [RankingCellModel]
}

struct RankingCellModel {
    let rank: Int
    let profileID: String
    let score: Int
}
