//
//  ChallengeDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import Foundation

struct ChallengeDataModel {
    let fileUrl: URL?
    let title: String
    let description: String
    let expireTimestamp: Date
    let fromUser: UserDataModel
    let previewImage: Data
}
