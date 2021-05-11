//
//  ChallengeCardViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

struct ChallengeCardViewModel {
    let coreDataID: ObjectIdentifier?
    let image: UIImage?
    let title: String
    let description: String
    let tag: ColorLabelViewModel?
    let timeLeftText: String?
    let isReceived: Bool
    let friendBubbles: [UserViewModel]?
    let senderProfile: UserViewModel?
    let completionState: ChallengeCompletionState
}
