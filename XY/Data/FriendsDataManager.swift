//
//  FriendsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit
import CoreData

final class FriendsDataManager {
    static var shared = FriendsDataManager()
    
    var allUsers: [UserDataModel]
    var friends: [UserDataModel]
    
    private init() {
        allUsers = []
        friends = []
    }
    
    func getBubbleFromData(dataModel: UserDataModel) -> FriendBubbleViewModel {
        return FriendBubbleViewModel(image: UIImage(data: dataModel.profileImage!)!, nickname: dataModel.nickname!)
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
    
    func updateFriendStatus(friend: FriendBubbleViewModel, newStatus: FriendStatus) {
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            var friend = allUsers[index]
            friend.friendStatus = newStatus.rawValue
            allUsers[index] = friend
        }
    }
    
    func updateFriendStatus(friend: UserDataModel, newStatus: FriendStatus) {
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            var friend = allUsers[index]
            friend.friendStatus = newStatus.rawValue
            allUsers[index] = friend
        }
    }
    
    func updateFriendStatus(friend: FriendListViewModel, newStatus: AddFriendButton.Mode) {
        let status:FriendStatus =
            {
                switch newStatus {
                case .add:
                    return .none
                case .addBack:
                    return .addedMe
                case .added:
                    return .added
                case .friend:
                    return .friend
                case .none:
                    return .none
                }
            }()
        
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            var friend = allUsers[index]
            friend.friendStatus = status.rawValue
            allUsers[index] = friend
        }
    }
    
    func updateFriendStatus(friend: ProfileViewModel, newStatus: AddFriendButton.Mode) {
        let status:FriendStatus =
            {
                switch newStatus {
                case .add:
                    return .none
                case .addBack:
                    return .addedMe
                case .added:
                    return .added
                case .friend:
                    return .friend
                case .none:
                    return .none
                }
            }()
        
        if let index = allUsers.firstIndex(where: { $0.nickname == friend.nickname }) {
            var friend = allUsers[index]
            friend.friendStatus = status.rawValue
            allUsers[index] = friend
        }
    }
    
    func profileFrom(_ viewModel: FriendListViewModel) -> ProfileViewModel? {
        if let index = allUsers.firstIndex(where: { $0.nickname == viewModel.nickname }) {
            var friend = allUsers[index]
            return friend.toProfile()
        } else {
            return nil
        }
    }
}


