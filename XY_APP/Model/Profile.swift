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
    var coverPhoto:UIImage?
    var profilePhoto:UIImage?
    var aboutMe:String?
    var fullName: String?
    var location: String?
    
    var imageToEdit:String?
    
    mutating func setImageToEdit(_ imageToEdit:String) {
        switch imageToEdit {
        case "profilePicture":
            self.imageToEdit = "profilePicture"
        case "coverPicture":
            self.imageToEdit = "coverPicture"
        default:
            fatalError()
        }
    }
    
    struct EditProfileRequestMessage: Codable {
        var profilePhotoId: String?
        var coverPhotoId: String?
        var fullName: String?
        var location: String?
        var aboutMe: String?
    }
    
    static func sendEditProfileRequest(requestMessage: EditProfileRequestMessage, completion: @escaping(Result<ResponseMessage, Error>) -> Void) {
        // Make API request to backend to edit profile.
        var editProfileRequest = APIRequest(endpoint: "edit_profile", httpMethod: "POST")
        let response = ResponseMessage()
        // Check LoginRequestMessage is valid
        editProfileRequest.save(message: requestMessage, response: response, completion: { result in
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
        var coverPhotoId: String?
        var fullName: String?
        var aboutMe: String?
        var location: String?
    }
    
    // Make backend request to get info on <username>'s profile.
    static func getProfile(username: String, completion: @escaping(Result<Profile, Error>) -> Void) {
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
                    profile.coverPhotoId = responseMessage.coverPhotoId
                    profile.aboutMe = responseMessage.aboutMe
                    profile.fullName = responseMessage.fullName
                    profile.location = responseMessage.location
                    DispatchQueue.main.async {
                        completion(.success(profile))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    public mutating func imagePickerHandler(_ imagePicked: UIImage, completion: @escaping(Result<(),Error>) -> Void) {
        // Set new profile image
        switch imageToEdit {
        case "profilePicture":
            coverPhoto = imagePicked
        case "coverPicture":
            profilePhoto = imagePicked
        default:
            break
        }
        
        let imageToEdit = self.imageToEdit
    
        // Upload the photo - save photo ID
        let imageManager = ImageManager()
        imageManager.uploadImage(image: imagePicked, completionHandler: { result in
            print("Uploaded profile image with response: ", result.message)
            
            let imageId = result.id
            let profilePicture:String?
            let coverPicture:String?
            
            switch imageToEdit {
            case "profilePicture":
                coverPicture = nil
                profilePicture = imageId
            case "coverPicture":
                coverPicture = imageId
                profilePicture = nil
            default:
                coverPicture = nil
                profilePicture = nil
            }
            
            // Set profile to use this photo ID
            let editProfileRequest = Profile.EditProfileRequestMessage(profilePhotoId: profilePicture, coverPhotoId: coverPicture, fullName: "Maxime Franchot", location: "Torino", aboutMe: "I'm XY's CTO.")
            Profile.sendEditProfileRequest(requestMessage: editProfileRequest, completion: {result in
                switch result {
                case .success(_):
                    completion(.success(()))

                case .failure(let error):
                    completion(.failure(error))
                }
            })
        })
    }
}
