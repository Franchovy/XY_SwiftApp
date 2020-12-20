//
//  Post.swift
//  XY_APP
//
//  Created by Maxime Franchot on 28/11/2020.
//

import Foundation
import UIKit

struct PostData: Codable {
    var id: String
    var username: String
    var timestamp: Date
    var content: String
    var images: [String]?
}

