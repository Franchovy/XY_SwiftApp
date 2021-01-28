//
//  ProfileManager.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import Foundation

final class ProfileManager {
    static let shared = ProfileManager()
    private init () { }

    func fetchProfile(profileId: String, completion: @escaping(Result<ProfileModel, Error>) -> Void) {
        fatalError("Please implement this")
    }
    
    func fetchProfile(userId: String, completion: @escaping(Result<ProfileModel, Error>) -> Void) {
    
        // Fetch profileId for userId
        FirebaseDownload.getProfileId(userId: userId) { [weak self] (profileId, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let profileId = profileId else {
                return
            }
            
            FirebaseDownload.getProfile(profileId: profileId) { (profileModel, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                guard let profileModel = profileModel else {
                    return
                }
                
                completion(.success(profileModel))
                
            }
        }
    }
}
