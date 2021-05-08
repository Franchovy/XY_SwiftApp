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
            type: notificationType.toViewModelType(),
            user: fromUser!.toViewModel()
        )
    }
}

extension NotificationType {
    func toViewModelType() -> NotificationViewModelType {
        switch self {
        case .addedYou:
            return .friendStatus(buttonStatus: .addedMe)
        case .challengedYou:
            return .challengeAction(image: UIImage(named: "challenge1")!)
        case .acceptedChallenge, .completedChallenge, .rejectedChallenge:
            return .challengeStatus(image: UIImage(named: "challenge1")!, status: true)
        }
    }
    
    func displayText() -> String {
        switch self {
        case .addedYou:
            return "Added you as a friend!"
        case .acceptedChallenge:
            return "Accepted to perform your challenge"
        case .rejectedChallenge:
            return "Rejected your challenge"
        case .challengedYou:
            return "Challenged you!"
        case .completedChallenge:
            return "Completed your challenge"
        }
    }
}
