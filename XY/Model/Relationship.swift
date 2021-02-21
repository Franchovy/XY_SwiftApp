//
//  Relationship.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import Foundation

enum RelationshipTypeForSelf {
    case following
    case follower
    case none
    case friends
}

enum RelationshipType: String {
    case follow
    case friends
}

struct Relationship {
    let id: String
    var type: RelationshipType
    let user1ID: String
    let user2ID: String
}

extension Relationship {
    
    /// New relationship
    init(user1ID: String, user2ID: String, type: RelationshipType, id: String) {
        self.user1ID = user1ID
        self.user2ID = user2ID
        self.type = type
        self.id = id
    }
    
    /// Initializer for data from firebase
    init(_ data: [String: Any], id: String) {
        self.id = id
        self.type = RelationshipType(rawValue: data[FirebaseKeys.RelationshipKeys.type] as! String)!
        
        var users = data[FirebaseKeys.RelationshipKeys.users] as! [String: Bool]
        switch type {
        case .follow:
            // For Follow Relationships, User1 follows User2
            var u1: String!
            var u2: String!
            
            for user in users {
                if user.value == true {
                    u1 = user.key
                } else {
                    u2 = user.key
                }
            }
            user1ID = u1
            user2ID = u2
        case .friends:
            user1ID = users.popFirst()!.key
            user2ID = users.popFirst()!.key
        }
    }
    
    func toData() -> [String: Any] {
        if type == .follow {
            return [
                FirebaseKeys.RelationshipKeys.type: type.rawValue,
                FirebaseKeys.RelationshipKeys.users: [
                    user1ID : true,
                    user2ID : false
                ]
            ]
        } else {
            return [
                FirebaseKeys.RelationshipKeys.type: type.rawValue,
                FirebaseKeys.RelationshipKeys.users: [
                    user1ID : true,
                    user2ID : true
                ]
            ]
        }
    }
    
    func toRelationshipToSelfType() -> RelationshipTypeForSelf {
        guard let userId = AuthManager.shared.userId,
              user1ID == userId || user2ID == userId
              else {
            return .none
        }
        
        if type == .friends { return .friends }
        
        if user1ID == userId {
            if type == .follow {
                return .following
            }
        } else if user2ID == userId {
            if type == .follow {
                return .follower
            }
        }
        return .none
    }
}

