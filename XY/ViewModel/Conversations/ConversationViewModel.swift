//
//  ConversationViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

struct ConversationViewModel {
    let id: String
    let image: UIImage?
    let name: String
    let lastMessageText: String
    let lastMessageTimestamp: Date
    let unread: Bool
}
