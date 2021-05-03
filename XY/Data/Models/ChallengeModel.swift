//
//  ChallengeModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/05/2021.
//

import Foundation

struct ChallengeModel {
    var title: String
    var challengeDescription: String
    var expiryTimestamp: Date
    var firebaseID: String
    var completionState: ChallengeCompletionState
    var fromUserFirebaseID: String
    var image: Data?
}
