//
//  Profile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation
import UIKit

struct Profile {
    var username:String?
    var coverPhotoId:String?
    var profilePhotoId:String?
    var aboutMe:String?
    
    init() {
        
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
    
    static func sendEditProfileRequest(imageId: String, completion: @escaping(Result<ResponseMessage, Error>) -> Void) {
        // Make API request to backend to edit profile.
        var editProfileRequest = APIRequest(endpoint: "edit_profile", httpMethod: "POST")
        let editProfileRequestMessage = EditProfileRequestMessage(profilePhotoId: imageId, aboutMe: "Hello, XYBrother. I am on XY!")
        let response = ResponseMessage()
        // Check LoginRequestMessage is valid
        editProfileRequest.save(message: editProfileRequestMessage, response: response, completion: { result in
            switch result {
            case .success(let message):
                if let message = message.message {
                    print("Successful change profile photo request response: \"" + message + "\"")
                }
                DispatchQueue.main.async {
                    completion(.success(message))
                }
                
            case .failure(let error):
                print("An error occured changing profile image: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
         }
        })
    }
    
    struct GetProfilePicIdRequestMessage: Codable {
        var username:String
    }
    
    struct GetProfilePicIdResponseMessage: Codable {
        var message:String?
        var profilePhotoId:String?
    }
    
    static func getProfile(username: String, completion: @escaping(Result<Profile, Error>) -> Void) {
        // Make backend request to get info on <username>'s profile.
        var getProfileRequest = APIRequest(endpoint: "get_profile", httpMethod: "GET")
        let response = GetProfilePicIdResponseMessage()
        
        let getProfileRequestMessage = GetRequestEmptyMessage()
        getProfileRequest.setHeader(headerFieldName: "username", headerValue: username)
        
        getProfileRequest.save(message: getProfileRequestMessage, response: response, completion: { result in
            switch result {
            case .success(let responseMessage):
                if (responseMessage.profilePhotoId != nil) {
                    var profile = Profile()
                    profile.profilePhotoId = responseMessage.profilePhotoId
                    completion(.success(profile))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
