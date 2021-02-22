//
//  NewPostViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 19/02/2021.
//

import UIKit

struct NewPostViewModel {
    var id: String
    var nickname: String
    var timestamp: Date
    var content: String
    var profileId: String
    var profileImage: UIImage?
    var image: UIImage?
    
    var loading: Bool = false
}
