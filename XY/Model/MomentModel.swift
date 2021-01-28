//
//  MomentModel.swift
//  XY
//
//  Created by Maxime Franchot on 23/01/2021.
//

import Foundation

struct MomentModel {
    let momentId: String
    let videoRef: String
    let caption: String
    let authorId: String
    
    
    init(from data: [String : Any], id: String) {
        momentId = id
        videoRef = data[FirebaseKeys.MomentsKeys.videoRef] as! String
        caption = "Moments on XY"
        authorId = data[FirebaseKeys.MomentsKeys.author] as! String
    }
}
