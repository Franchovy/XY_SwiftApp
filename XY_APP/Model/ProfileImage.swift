//
//  ProfileImage.swift
//  XY_APP
//
//  Created by Maxime Franchot on 05/12/2020.
//

import Foundation
import UIKit

class ProfileImage {
    
    var image: UIImage
    
    init(image:UIImage?) {
        if let image = image {
            self.image = image
        } else {
            self.image = UIImage(named:"profile")!
        }
    }
    
    func uploadImage(newProfileImage: UIImage) {
        // Set new profile image
        let newProfileImage = newProfileImage
        // Upload the photo - save photo ID
        let imageManager = ImageManager()
        // Upload image
        imageManager.uploadImage(image: newProfileImage, completionHandler: { result in
            print("Uploaded profile image with response: ", result.message)
            if result.id != "" {
                print("Image uploaded with id ", result.id)
                let imageId = result.id
                // Set profile to use this photo ID
                let editProfileRequest = Profile.EditProfileRequestMessage(profilePhotoId: imageId, coverPhotoId: nil, fullName: nil, location: nil, aboutMe: nil)
                Profile.sendEditProfileRequest(requestMessage: editProfileRequest, completion: {result in
                    switch result {
                    case .success(let message):
                        print("Successfully edited profile: ", message)
                    case .failure(let error):
                        print("Error editing profile: ", error)
                    }
                })
            }
        })
    }
    
    static func getImage(imageId:String, completion: @escaping(UIImage?) -> Void) {
        let imageManager = ImageManager()
        // get image test
        imageManager.downloadImage(imageID: imageId, completion: {resultImage in
            if let resultImage = resultImage {
                completion(resultImage)
            } else {
                completion(nil)
            }
        })
    }
}
