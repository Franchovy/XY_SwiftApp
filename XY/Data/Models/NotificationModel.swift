//
//  NotificationModel.swift
//  XY
//
//  Created by Maxime Franchot on 07/05/2021.
//

import Foundation

enum NotificationType: String {
    case addedYou
    case challengedYou
    case acceptedChallenge
    case rejectedChallenge
    case completedChallenge
}

struct NotificationModel {
    var firebaseID: String
    var fromUserFirebaseID: String
    var challengeFirebaseID: String?
    var timestamp: Date
    var type: NotificationType
}
