//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit
import Firebase

struct PostData : FlowDataModel {
    var type: FlowDataType = .post
    
    var id: String
    var userId: String
    var profileImage: String?
    var timestamp: Date
    var content: String
    var images: [String]?
    
    var level: Int
    var xp: Int
}

extension PostData {
    func toUpload() -> [String: Any] {
        return [
            FirebaseKeys.PostKeys.author : userId,
            FirebaseKeys.PostKeys.timestamp : FieldValue.serverTimestamp(),
            FirebaseKeys.PostKeys.level : level,
            FirebaseKeys.PostKeys.xp : xp,
            FirebaseKeys.PostKeys.postData : [
                FirebaseKeys.PostKeys.PostData.caption : content,
                FirebaseKeys.PostKeys.PostData.imageRef : images!.first
            ]
        ]
    }
}
