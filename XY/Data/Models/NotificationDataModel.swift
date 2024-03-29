//
//  NotificationDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 08/05/2021.
//

import UIKit

extension NotificationDataModel {
    func toViewModel() -> NotificationViewModel {
        let notificationType = NotificationType(rawValue: type!)!
        
        return NotificationViewModel(
            notificationText: notificationType.displayText(),
            timestampText: timestamp!.timeAgo(),
            timestamp: timestamp!,
            type: notificationType.toViewModelType(),
            challengeImage: challenge?.previewImage != nil ? UIImage(data: challenge!.previewImage!) : nil,
            user: fromUser!.toViewModel()
        )
    }
}

extension NotificationType {
    func toViewModelType() -> NotificationViewModelType {
        switch self {
        case .addedYou:
            return .friendStatus
        case .challengedYou:
            return .challengeAction
        case .acceptedChallenge:
            return .challengeStatus(status: .accepted)
        case .completedChallenge:
            return .challengeStatus(status: .complete)
        case .rejectedChallenge:
            return .challengeStatus(status: .rejected)
        }
    }
    
    func displayText() -> String {
        switch self {
        case .addedYou:
            return "Added you as a friend!"
        case .acceptedChallenge:
            return "Accepted your challenge"
        case .rejectedChallenge:
            return "Rejected your challenge"
        case .challengedYou:
            return "Sent you a challenge"
        case .completedChallenge:
            return "Completed your challenge"
        }
    }
}
