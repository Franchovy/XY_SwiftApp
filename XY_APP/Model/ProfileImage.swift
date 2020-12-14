//
//  ProfileImage.swift
//  XY_APP
//
//  Created by Maxime Franchot on 05/12/2020.
//

import Foundation
import UIKit

class ProfileImage {
    var user: Profile
    var imageId:String
    var image: UIImage?
    
    init(user:Profile, imageId:String) {
        self.imageId = imageId
        self.user = user
    }
    
    func getNavigationToProfile() {
        // returns UIViewController to navigate to the profile of the owner user.
    }
    
    func getProfilePreview() {
        // returns preview card of profile to advertise.
    }
    
    // Loads the image from the backend.
    func load(_ completion: @escaping(UIImage) -> Void) {
        ImageManager.downloadImage(imageID: imageId, completion: {resultImage in
            if let resultImage = resultImage {
                self.image = resultImage
                completion(resultImage)
            }
        })
    }
}
