//
//  NotificationViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

enum NotificationType {
    case challengeAction(image: UIImage)
    case challengeStatus(image: UIImage, status: Bool)
    case friendStatus(buttonStatus: AddFriendButton.Mode)
}

struct NotificationViewModel {
    var nickname: String
    var profileImage: UIImage
    var notificationText: String
    var timestampText: String
    var type: NotificationType
}
