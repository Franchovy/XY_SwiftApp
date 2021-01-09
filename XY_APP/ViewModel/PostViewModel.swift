//
//  PostViewModel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import FirebaseStorage

protocol PostViewModelDelegate: NSObjectProtocol {
    func didFetchProfileData(xyname: String)
    func didFetchProfileImage()
    func didFetchPostImages()
}

class PostViewModel {
    weak var delegate: PostViewModelDelegate?
    
    var data: PostData? {
        didSet {
            guard let data = data else { return }
            
            // Set normal properties
            content = data.content
            timestamp = data.timestamp
            imageIds = data.images
            
            //TODO: Get profileData for userId
            
            let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(data.userId)
            userDocument.getDocument() { document, error in
                if let error = error {
                    print("Error fetching user data: \(error)")
                }
                
                if let documentData = document?.data() {
                    // Get profile data
                    let profileId = documentData[FirebaseKeys.UserKeys.profile] as! String
                    let profileDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                    profileDoc.getDocument() { document, error in
                        if let error = error {
                            print("Error fetching profile data: \(error)")
                        }
                        if let documentData = document?.data() {
                            // Set XYName
                            self.xyname = documentData[FirebaseKeys.ProfileKeys.nickname] as! String
                            self.delegate?.didFetchProfileData(xyname: self.xyname!)
                            // Set profileImageId
                            self.profileImageId = documentData[FirebaseKeys.ProfileKeys.image] as! String
                        }
                    }
                }
            }
            
            
        }
    }
    
    var xyname: String?
    var timestamp: Date?
    var content: String?
    
    var profileImageId: String? {
        didSet {
            guard let profileImageId = profileImageId else { return }
            
            let storage = Storage.storage()
            let ref = storage.reference(withPath: profileImageId)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching profile image: \(error)")
                }
                if let data = data, let image = UIImage(data: data) {
                    self.profileImage = image
                    self.delegate?.didFetchProfileImage()
                }
            }
        }
    }
    
    var imageIds: [String]? {
        didSet {
            guard let imageIds = imageIds else { return }

            let storage = Storage.storage()
            for imageId in imageIds {
                
                let ref = storage.reference(withPath: imageId)
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error fetching image: \(error)")
                    }
                    if let data = data, let image = UIImage(data: data) {
                        self.images.append(image)
                        
                        // If all images have been fetched, call the delegate completion.
                        if self.images.count == self.imageIds?.count {
                            self.delegate?.didFetchPostImages()
                        }
                    }
                }
            }
        }
    }
    
    var profileImage: UIImage?
    var images: [UIImage] = []
    
    // MARK: - Public Methods
    
    
    func getTimestampString() -> String {
        if let timestamp = timestamp {
            return timestamp.description
        } else {
            return ""
        }
    }
}
