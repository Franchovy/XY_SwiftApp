//
//  NotificationViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

enum NotificationViewModelType {
    case challengeAction(image: UIImage)
    case challengeStatus(image: UIImage, status: Bool)
    case friendStatus(buttonStatus: FriendStatus)
}

struct NotificationViewModel {
    var notificationText: String
    var timestampText: String
    var type: NotificationViewModelType
    var user: UserViewModel
}
