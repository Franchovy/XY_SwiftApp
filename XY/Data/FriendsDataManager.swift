//
//  FriendsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData

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
    
    var allUsers: [UserDataModel]
    var friends: [UserDataModel]
    
    private init() {
        allUsers = []
        friends = []
    }
    
    var changeListeners: [UserViewModel: [WeakReferenceListener]] = [:]
    
    func registerChangeListener(for viewModel: UserViewModel, listener: FriendsDataManagerListener) {
        if changeListeners[viewModel] != nil {
            changeListeners[viewModel]!.append(WeakReferenceListener(listener))
        } else {
            changeListeners[viewModel] = [WeakReferenceListener(listener)]
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
    
    func loadDataFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            allUsers = results
            
            #if DEBUG
            if allUsers.count == 0 {
                for _ in 0...100 {
                    allUsers.append(UserDataModel.fakeUser())
                }
            }
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
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            let friendModel = allUsers[index]
            friendModel.friendStatus = newStatus.rawValue
            allUsers[index] = friendModel
            
            changeListeners[friend]?.forEach({ $0.reference?.didUpdateFriendshipState(to: newStatus ) })
        }
    }
}


