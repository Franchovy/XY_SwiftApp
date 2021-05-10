//
//  NotificationViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

enum NotificationViewModelType {
    case challengeAction
    case challengeStatus(status: ChallengeCompletionState)
    case friendStatus
}

struct NotificationViewModel {
    var notificationText: String
    var timestampText: String
    var type: NotificationViewModelType
    var challengeImage: UIImage?
    var user: UserViewModel
}
