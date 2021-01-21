//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit
import Firebase

struct PostModel : FlowDataModel {
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

extension PostModel {
    init(from data: [String: Any], id: String) {
        self.id = id
        userId = data[FirebaseKeys.PostKeys.author] as! String
        timestamp = (data[FirebaseKeys.PostKeys.timestamp] as? Firebase.Timestamp)?.dateValue() ?? Date()
        level = data[FirebaseKeys.PostKeys.level] as! Int
        xp = data[FirebaseKeys.PostKeys.xp] as! Int
        
        let postData = data[FirebaseKeys.PostKeys.postData] as! [String: Any]
        content = postData[FirebaseKeys.PostKeys.PostData.caption] as! String
        images = [ postData[FirebaseKeys.PostKeys.PostData.imageRef] as! String ]
    }
    
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
