//
//  FirebaseStoragePaths.swift
//  XY
//
//  Created by Maxime Franchot on 19/04/2021.
//

import Foundation

final class FirebaseStoragePaths {
    static func profileImagePath(userId: String, imageID: String) -> String {
        "\(userId)/\(imageID)_profileImg.png"
    }
    
    static func challengeVideoPath(challengeId: String, videoId: String) -> String {
        "\(challengeId)/\(videoId).mov"
    }
    
    static func challengeVideoPathHD(challengeId: String, videoId: String) -> String {
        "\(challengeId)/\(videoId)/processed/hd.mp4"
    }
    
    static func challengeVideoPathSD(challengeId: String, videoId: String) -> String {
        "\(challengeId)/\(videoId)/processed/sd.mp4"
    }
    
    static func challengePreviewImgPath(challengeId: String) -> String {
        "\(challengeId)/\(challengeId).png"
    }
}
