//
//  SendCollectionViewCellViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

struct SendCollectionViewCellViewModel: Comparable {
    var profileImage: UIImage
    var nickname: String
    var buttonStatus: AddFriendButton.Mode
    
    static func < (lhs: SendCollectionViewCellViewModel, rhs: SendCollectionViewCellViewModel) -> Bool {
        return lhs.nickname < rhs.nickname
    }
}
