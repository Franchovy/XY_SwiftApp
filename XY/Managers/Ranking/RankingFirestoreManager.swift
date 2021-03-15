//
//  RankingFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import Foundation

struct RankingID {
    let userID: String
    let profileID: String
}

class RankingFirestoreManager {
    static var shared = RankingFirestoreManager()
    private init() { }
    
    func getTopRanking(rankingLength: Int, completion: @escaping([RankingID]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var userRanking = [RankingID?](repeating: nil, count: rankingLength)
        
        dispatchGroup.enter()
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .order(by: FirebaseKeys.UserKeys.level, descending: true)
            .order(by: FirebaseKeys.UserKeys.xp, descending: true)
            .limit(to: rankingLength)
            .getDocuments { (querySnapshot, error) in
                defer {
                    dispatchGroup.leave()
                }
                if let querySnapshot = querySnapshot {
                    let userIDs = querySnapshot.documents
                        .filter( { !($0.data().keys.contains("hidden") && $0.data()["hidden"] as! Bool) } )
                        .map({ $0.documentID })
                    
                    userIDs.enumerated().forEach { (index, userID) in
                        dispatchGroup.enter()
                        ProfileFirestoreManager.shared.getProfileID(forUserID: userID) { profileID, error in
                            defer {
                                dispatchGroup.leave()
                            }
                            if let profileID = profileID {
                                userRanking[index] =
                                    RankingID(
                                        userID: userID,
                                        profileID: profileID
                                    )
                            }
                        }
                    }
                }
            }
        
        dispatchGroup.notify(queue: .main, work: DispatchWorkItem(block: {
            completion(userRanking.compactMap({ $0 }))
        }))
    }
    
    func getFriendsRanking(rankingLength: Int, completion: @escaping([RankingID]?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var userRanking = [RankingID?](repeating: nil, count: 99)
        
        dispatchGroup.enter()
        
        var followingIDs = [String]()
        if let userID = AuthManager.shared.userId {
            followingIDs.append(userID)
        }
        
        if FlowAlgorithmManager.shared.followingInitialized {
            followingIDs.append(contentsOf: FlowAlgorithmManager.shared.followingIDs)
        } else {
            dispatchGroup.enter()
            
            FlowAlgorithmManager.shared.initialiseFollowing {
                defer {
                    dispatchGroup.leave()
                }
                followingIDs.append(contentsOf: FlowAlgorithmManager.shared.followingIDs)
            }
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .order(by: FirebaseKeys.UserKeys.level, descending: true)
            .order(by: FirebaseKeys.UserKeys.xp, descending: true)
            .limit(to: 99)
            .getDocuments { (querySnapshot, error) in
                defer {
                    dispatchGroup.leave()
                }
                if let querySnapshot = querySnapshot {
                    let userIDs = querySnapshot.documents
                        .filter( { !($0.data().keys.contains("hidden") && $0.data()["hidden"] as! Bool) } )
                        .map({ $0.documentID })
                    
                    userIDs.enumerated().forEach { (index, userID) in
                        dispatchGroup.enter()
                        ProfileFirestoreManager.shared.getProfileID(forUserID: userID) { profileID, error in
                            defer {
                                dispatchGroup.leave()
                            }
                            if let profileID = profileID {
                                userRanking[index] =
                                    RankingID(
                                        userID: userID,
                                        profileID: profileID
                                    )
                            }
                        }
                    }
                }
            }
        
        dispatchGroup.notify(queue: .main, work: DispatchWorkItem(block: {
            let arraySlice = userRanking
                .compactMap({ $0 })
                .filter({ followingIDs.contains($0!.userID) })
                .compactMap({ $0 })
                .prefix(rankingLength)
            completion(Array(arraySlice))
        }))
    }
    
}
