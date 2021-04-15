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
        if let user = allUsers.first(where: { $0.nickname == friend.nickname }) {
            
            user.friendStatus = newStatus.rawValue
            
            changeListeners[user]?.forEach({ $0.reference?.didUpdateFriendshipState(to: newStatus ) })
            
            #if DEBUG
            
            if newStatus == .added {
                Timer.scheduledTimer(timeInterval: TimeInterval.seconds(5), target: self, selector: #selector(fakeFriendAddBack(_:)), userInfo: ["nickname": friend.nickname], repeats: false)
            }
            
            #endif
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


