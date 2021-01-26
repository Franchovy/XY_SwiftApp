//
//  ViralModel.swift
//  XY
//
//  Created by Maxime Franchot on 26/01/2021.
//

import Foundation

struct ViralModel {
    let id: String
    let videoRef: String
    let caption: String
    let user: String
    let level: Int
    let xp: Int
    let lives: Int
    
    init(from data: [String : Any], id: String) {
        self.id = id
        videoRef = data[FirebaseKeys.ViralKeys.videoRef] as! String
        caption = data[FirebaseKeys.ViralKeys.caption] as! String
        user = data[FirebaseKeys.ViralKeys.user] as! String
        level = data[FirebaseKeys.ViralKeys.level] as! Int
        xp = data[FirebaseKeys.ViralKeys.xp] as! Int
        lives = data[FirebaseKeys.ViralKeys.livesLeft] as! Int
    }
}
