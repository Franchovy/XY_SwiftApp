//
//  FriendsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData

extension NSNotification.Name {
    static let friendUpdateNotification = Notification.Name("friendUpdateNotification")
}

final class WeakReferenceListener {
    init(_ listener: FriendsDataManagerListener) {
        reference = listener
    }
    
    weak var reference: FriendsDataManagerListener?
}

protocol FriendsDataManagerListener: NSObject {
    func didUpdateFriendshipState(to state: FriendStatus)
    func didUpdateProfileImage(to image: UIImage)
    func didUpdateNickname(to nickname: String)
    func didUpdateNumFriends(to numFriends: Int)
    func didUpdateNumChallenges(to numChallenges: Int)
}

final class FriendsDataManager {
    static var shared = FriendsDataManager()
    private init() {
        allUsers = []
    }
    
    var allUsers: [UserDataModel]
    var friends: [UserDataModel] {
        get {
            allUsers.filter({ $0.friendStatus == FriendStatus.friend.rawValue })
        }
    }
    
    var changeListeners: [UserDataModel: [WeakReferenceListener]] = [:]
    
    func registerChangeListener(for viewModel: UserViewModel, listener: FriendsDataManagerListener) {
        guard let dataModel = getDataModel(for: viewModel) else {
            return
        }
        
        if changeListeners[dataModel] != nil {
            changeListeners[dataModel]!.append(WeakReferenceListener(listener))
        } else {
            changeListeners[dataModel] = [WeakReferenceListener(listener)]
        }
    }
    
    func clearNilListeners() {
        for var changeListener in changeListeners {
            changeListener.value.removeAll(where: {$0.reference == nil})
            if changeListener.value.count == 0 {
                changeListeners.removeValue(forKey: changeListener.key)
            }
        }
    }
    
    func deregisterChangeListener(listener: FriendsDataManagerListener) {
        
        let listenersWithListener = changeListeners.filter({ $0.value.contains(where: { $0.reference != nil && $0.reference! == listener }) })
        
        for keyValuePair in listenersWithListener {
            if keyValuePair.value.count == 1 {
                changeListeners.removeValue(forKey: keyValuePair.key)
            } else {
                changeListeners[keyValuePair.key]?.removeAll(where: { $0.reference != nil && $0.reference! == listener })
            }
        }
        
        clearNilListeners()
    }
    
    func getUserWithFirebaseID(_ firebaseID: String) -> UserDataModel? {
        return allUsers.first(where: { $0.firebaseID == firebaseID })
    }
    
    func getDataModel(for viewModel: UserViewModel) -> UserDataModel? {
        return allUsers.first(where: { $0.id == viewModel.coreDataID })
    }
    
    func getOrCreateUserWithFirestoreID(id: String) -> UserDataModel? {
        let context = CoreDataManager.shared.mainContext
        
        let fetchRequest:NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firebaseID == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try context.fetch(fetchRequest)
            
            // Return new user document if not found
            if result.isEmpty {
                
                let entity = UserDataModel.entity()
                let model = UserDataModel(entity: entity, insertInto: context)
                model.firebaseID = id
                
                return model
            } else {
                return result.first
            }
        } catch let error {
            print("Error fetching for user with id: \(id) due to error: \(error)")
            return nil
        }
    }
    
    
    
    func loadAllUsersFromFirebase(completion: @escaping(() -> Void)) {
        FirebaseFirestoreManager.shared.fetchAllProfiles { (result) in
            switch result {
            case .success(let userModels):
                for userModel in userModels {
                    if !self.allUsers.contains(where: { $0.firebaseID == userModel.firebaseID }) {
                        // Add user to all Users
                        let newUserDataModel = self.createUser(userModel: userModel)
                        self.allUsers.append(newUserDataModel)
                        self.downloadProfileImageForUser(userModel: newUserDataModel)
                        
                    } else if self.allUsers.contains(where: { $0.firebaseID == userModel.firebaseID }) {
                        if let userDataModel = self.allUsers.first(where: { $0.firebaseID == userModel.firebaseID }) {
                            // Download new image
                            if userDataModel.profileImageFirebaseID != userModel.profileImageFirebaseID {
                                userDataModel.profileImageFirebaseID = userModel.profileImageFirebaseID
                                
                                self.downloadProfileImageForUser(userModel: userDataModel)
                            }
                            
                            if userDataModel.nickname != userModel.nickname {
                                userDataModel.nickname = userModel.nickname
                                
                                self.updateNicknameForUser(userModel: userDataModel)
                            }
                            
                            if userDataModel.numFriends != userModel.numFriends {
                                userDataModel.numFriends = Int16(userModel.numFriends)
                                
                                self.changeListeners[userDataModel]?.forEach({ $0.reference?.didUpdateNumFriends(to: userModel.numFriends) })
                            }
                            
                            if userDataModel.numChallenges != userModel.numChallenges {
                                userDataModel.numChallenges = Int16(userModel.numChallenges)
                                
                                self.changeListeners[userDataModel]?.forEach({ $0.reference?.didUpdateNumChallenges(to: userModel.numChallenges) })
                            }
                        }
                    }
                }
                
                // Perform opposite check - delete users not present in firebase
                
                for user in self.allUsers {
                    if userModels.filter({$0.firebaseID == user.firebaseID}).count != 1 {
                        print("Delete user: \(user)")
                        CoreDataManager.shared.mainContext.delete(user)
                        self.allUsers.remove(at: self.allUsers.firstIndex(where: { $0.firebaseID == user.firebaseID })!)
                    
                    }
                }
                CoreDataManager.shared.save()
                
                completion()
            case .failure(let error):
                print("Error fetching users from firebase: \(error.localizedDescription)")
            }
        }
    }
    
    func createUser(userModel: UserModel) -> UserDataModel {
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()
        
        let model = UserDataModel(entity: entity, insertInto: context)
        model.firebaseID = userModel.firebaseID
        model.friendStatus = userModel.friendStatus.rawValue
        model.numFriends = Int16(userModel.numFriends)
        model.numChallenges = Int16(userModel.numChallenges)
        model.profileImageFirebaseID = userModel.profileImageFirebaseID
        model.nickname = userModel.nickname
        
        return model
    }
    
    func updateNicknameForUser(userModel: UserDataModel) {
        guard userModel.nickname != nil else { return }
        
        changeListeners[userModel]?.forEach({ $0.reference?.didUpdateNickname(to: userModel.nickname!) })
    }
    
    func setupListenerForUser(userDataModel: UserDataModel) {
        FirebaseFirestoreManager.shared.listenToUpdatesForUser(withID: userDataModel.firebaseID!) { result in
            switch result {
            case .success(let userDocument):
                
                if userDataModel.nickname != userDocument.nickname {
                    self.changeListeners[userDataModel]?.forEach({ $0.reference?.didUpdateNickname(to: userDocument.nickname)})
                }
                
                if userDataModel.numFriends != userDocument.numFriends {
                    self.changeListeners[userDataModel]?.forEach({ $0.reference?.didUpdateNumFriends(to: userDocument.numFriends)})
                }
                
                if userDataModel.numChallenges != userDocument.numChallenges {
                    self.changeListeners[userDataModel]?.forEach({ $0.reference?.didUpdateNumChallenges(to: userDocument.numChallenges)})
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadProfileImageForUser(userModel: UserDataModel) {
        guard let firebaseID = userModel.firebaseID, let profileImageFirebaseID = userModel.profileImageFirebaseID else {
            return
        }
        
        let path = FirebaseStoragePaths.profileImagePath(userId: firebaseID, imageID: profileImageFirebaseID)
        FirebaseStorageManager.shared.downloadImage(from: path) { (progress) in
            
        } completion: { (result) in
            switch result {
            case .success(let image):
                userModel.profileImage = image
                CoreDataManager.shared.save()
                
                self.changeListeners[userModel]?.forEach({ $0.reference?.didUpdateProfileImage(to: UIImage(data: image)!) })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func loadDataFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nickname != %@", ProfileDataManager.shared.nickname!)
        
        do {
            let results = try mainContext.fetch(fetchRequest)
            
            allUsers = results
            
            print("User profile image detection: \(allUsers.first(where: { $0.profileImageFirebaseID != nil }))")
            
            #if DEBUG
//            if allUsers.count == 0 {
//                for _ in 0...100 {
//                    allUsers.append(UserDataModel.fakeUser())
//                }
//            }
            #endif
        }
        catch {
            debugPrint(error)
        }
    }
    
    func saveToPersistent() {
        do {
            try CoreDataManager.shared.mainContext.save()
        } catch let error {
            print("Error saving context: \(error)")
        }
    }
    
    func getStateForUser(_ viewModel: UserViewModel) -> FriendStatus {
        if let userModel = allUsers.first(where: { $0.id == viewModel.coreDataID }) {
            return FriendStatus(rawValue: userModel.friendStatus!)!
        } else {
            return .none
        }
    }
    
    func updateFriendStatus(friend: UserViewModel, newStatus: FriendStatus) {
        if let user = allUsers.first(where: { $0.id == friend.coreDataID }) {
            user.friendStatus = newStatus.rawValue
            
            FirebaseFirestoreManager.shared.setFriendshipStatus(for: user) { (error) in
                if let error = error {
                    print("Error setting friendship status: \(error.localizedDescription)")
                }
            }
            
            // Update listeners
            changeListeners[user]?.forEach({ $0.reference?.didUpdateFriendshipState(to: newStatus ) })
            NotificationCenter.default.post(name: .friendUpdateNotification, object: nil)
        }
    }
    
    func setupFriendshipStatusListener() {
        // add firestore listener
        FirebaseFirestoreManager.shared.listenForFriendStatusUpdates() { userID, friendStatus, error in
            if let error = error {
                fatalError(error.localizedDescription)
            } else if let userID = userID, let friendStatus = friendStatus {
                // Set coredata
                if let user = self.allUsers.first(where: { $0.firebaseID == userID }) {
                    
                    user.friendStatus = friendStatus.rawValue
                    
                    // Update listeners
                    self.changeListeners[user]?.forEach({ $0.reference?.didUpdateFriendshipState(to: friendStatus ) })
                    NotificationCenter.default.post(name: .friendUpdateNotification, object: nil)
                }
            }
            
        }
    }
}


