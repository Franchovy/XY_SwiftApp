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
    
    func getDataModel(for viewModel: UserViewModel) -> UserDataModel? {
        return allUsers.first(where: { $0.nickname! == viewModel.nickname })
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
    
    func loadAllUsersFromFirebase() {
        FirebaseFirestoreManager.shared.fetchAllProfiles { (result) in
            switch result {
            case .success(let userModels):
                self.allUsers = userModels
            case .failure(let error):
                print("Error fetching users from firebase: \(error.localizedDescription)")
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
        if let userModel = allUsers.first(where: { $0.nickname == viewModel.nickname }) {
            return FriendStatus(rawValue: userModel.friendStatus!)!
        } else {
            return .none
        }
    }
    
    func updateFriendStatus(friend: UserViewModel, newStatus: FriendStatus) {
        if let user = allUsers.first(where: { $0.nickname == friend.nickname }) {
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
    
    #if DEBUG
    
    @objc private func fakeFriendAddBack(_ timer: Timer) {
        let nickname = (timer.userInfo as! [String: String])["nickname"]
        
        guard let user = allUsers.first(where: { $0.nickname == nickname }) else {
            return
        }
        let userViewModel = user.toViewModel()
        
        guard userViewModel.friendStatus == .added else {
            return
        }
        
        updateFriendStatus(friend: userViewModel, newStatus: .friend)
    }
    
    #endif
}


