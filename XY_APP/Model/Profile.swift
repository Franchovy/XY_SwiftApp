//
//  Profile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation
import UIKit

struct Profile {
    var username:String
    var coverPhoto:UIImage?
    var profilePhoto:UIImage?
    
    init(username : String) {
        self.username = username
    }
    
    // Backend API call to get profile data for this user
    func getProfile(completion: (Result<Bool, Error>)) {
        // create request
        // save request
        // set this profile attributes, coverPhoto & profilePhoto
        // call completionhandler
    }
    
    struct EditProfileRequestMessage: Codable {
        var profilePhotoId: String
        var aboutMe: String
    }
    
    static func sendEditProfileRequest(completion: @escaping(Result<ResponseMessage, Error>) -> Void) {
        // Make API request to backend to edit profile.
        let editProfileRequest = APIRequest(endpoint: "edit_profile", httpMethod: "POST")
        let editProfileRequestMessage = EditProfileRequestMessage(profilePhotoId: "57847d61-8212-4242-842c-898f85b18bb3", aboutMe: "I am on XY!")
        let response = ResponseMessage()
        // Check LoginRequestMessage is valid
        editProfileRequest.save(message: editProfileRequestMessage, response: response, completion: { result in
            switch result {
            case .success(let message):
                if let message = message.message {
                    print("POST request response: \"" + message + "\"")
                }
                DispatchQueue.main.async {
                    completion(.success(message))
                }
                
            case .failure(let error):
                print("An error occured: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
         }
        })
    }
}
