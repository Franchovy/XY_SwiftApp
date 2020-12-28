//
//  Profile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation
import UIKit



class Profile {
    
    // MARK: - DATA MODELS
    
    struct ProfileImage {
        var user: Profile
        var imageId:String
        var image: UIImage?
    }
    
    struct ProfileData : Codable {
        var username:String?
        var coverPhotoId:String?
        var profilePhotoId:String?
        var caption:String?
        var fullName: String?
        var location: String?
        var role: String?
        var birthdate: Date?
    }
    
    struct PasswordData {
        var password: String?
    }
    
    // MARK: - PROPERTIES
    
    static var ownedProfile:ProfileData?
    static var shared: Profile = Profile()
    
    var profileData:ProfileData?
    
    var coverPhoto:UIImage?
    var profilePhoto:UIImage?
    
    var imagePickedType:ImageToPickType = .profilePicture

    // MARK: - ENUMS
    
    enum ImageToPickType {
        case coverPicture
        case profilePicture
        case mood
        case post
    }
    
    enum LoadProfileError: Error {
        case connectionProblem
        case otherProblem
    }
    
    // MARK: - PUBLIC METHODS
    
    // Get profile details for this user
    func getProfile(username: String, closure: @escaping(Result<ProfileData, LoadProfileError>) -> Void) {
        Profile.getProfile(username: username, closure: closure)
    }
    
    func editProfile(data:ProfileData, closure: @escaping() -> Void) {
        
        Profile.sendEditProfileRequest(data: data, completion: { result in
            // TODO - Anything to do here?
            closure()
        })
    }
    
    // MARK: - API
    
    fileprivate struct EditProfileRequestMessage: Codable {
        var profilePhotoId: String?
        var coverPhotoId: String?
        var fullName: String?
        var location: String?
        var caption: String?
        var role: String?
        var birthdate: Date?
    }
    
    fileprivate static func sendEditProfileRequest(data: ProfileData, completion: @escaping(Result<ResponseMessage, Error>) -> Void) {
        // Make API request to backend to edit profile.
        let editProfileRequest = APIRequest(endpoint: "edit_profile", httpMethod: "POST")
        let response = ResponseMessage()
        // Check LoginRequestMessage is valid
        editProfileRequest.save(message: data, response: response, completion: { result in
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
    
    fileprivate struct GetProfilePicIdRequestMessage: Codable {
        var username:String
    }
    
    fileprivate struct GetProfilePicIdResponseMessage: Codable {
        var message:String?
        var profilePhotoId:String?
        var coverPhotoId: String?
        var fullName: String?
        var aboutMe: String?
        var location: String?
    }
    
    // Make backend request to get info on <username>'s profile.
    fileprivate static func getProfile(username: String, closure: @escaping(Result<ProfileData, LoadProfileError>) -> Void) {
        let getProfileRequest = APIRequest(endpoint: "get_profile", httpMethod: "GET")
        let response = GetProfilePicIdResponseMessage()
        
        let getProfileRequestMessage = GetRequestEmptyMessage()
        getProfileRequest.setHeader(headerFieldName: "username", headerValue: username)
        
        getProfileRequest.save(message: getProfileRequestMessage, response: response, completion: { result in
            switch result {
            case .success(let responseMessage):
                if (responseMessage.profilePhotoId != nil) {
                    closure(.success( //TODO UPDATE API FOR --- ABOUT_ME ----
                        ProfileData(username: username, coverPhotoId: responseMessage.coverPhotoId, profilePhotoId: responseMessage.profilePhotoId, caption: responseMessage.aboutMe, fullName: responseMessage.fullName, location: responseMessage.location)
                    ))
                }
            case .failure(let error):
                if error == .responseProblem {
                    closure(.failure(.connectionProblem))
                } else {
                    closure(.failure(.otherProblem))
                }
            }
        })
    }
}
