//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit


struct PostData : FlowDataModel {
    var type: FlowDataType = .post
    
    var id: String
    var userId: String
    var profileImage: String?
    var timestamp: Date
    var content: String
    var images: [String]?
}
