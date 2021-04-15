//
//  FriendsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData


extension Notification.Name {
    static let didUpdateStateForUser = Notification.Name("didReceiveChallenges")
}


final class FriendsDataManager {
    static var shared = FriendsDataManager()
    
    var allUsers: [UserDataModel]
    var friends: [UserDataModel]
    
    private init() {
        allUsers = []
        friends = []
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
    
    func updateFriendStatus(friend: UserViewModel, newStatus: FriendStatus) {
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            let friendModel = allUsers[index]
            friendModel.friendStatus = newStatus.rawValue
            allUsers[index] = friendModel
            
            NotificationCenter.default.post(name: .didUpdateStateForUser, object: friend)
        }
    }
}


