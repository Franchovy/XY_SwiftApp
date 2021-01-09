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
}

extension PostData {
    func toUpload() -> [String: Any] {
        return [
            FirebaseKeys.PostKeys.author : userId,
            FirebaseKeys.PostKeys.postData : [
                FirebaseKeys.PostKeys.PostData.caption : content,
                FirebaseKeys.PostKeys.PostData.imageRef : images!.first,
                FirebaseKeys.PostKeys.PostData.timestamp : FieldValue.serverTimestamp()
            ]
        ]
    }
}
