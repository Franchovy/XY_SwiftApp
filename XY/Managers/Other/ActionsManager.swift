//
//  ActionsManager.swift
//  XY
//
//  Created by Maxime Franchot on 05/02/2021.
//

import Foundation
import Firebase

final class ActionManager {
    static let shared = ActionManager()
    private init() { }
    
    var previousActions = [Action]()
    var swipeLeftUserIds = [String]()
    
    var forceUpdate = true
    
    /// Donwloads actions for this user, to be used for applications like posts or virals
    func getActions() {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        if forceUpdate == false, let previousSwipeLeftUserIds = UserDefaults.standard.stringArray(forKey: "previousActions") {
            swipeLeftUserIds = previousSwipeLeftUserIds
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.actions)
            .whereField(FirebaseKeys.ActionKeys.user, isEqualTo: userId).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching actions: \(error)")
                }
                
                self.previousActions = []
                
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        let action = Action(fromData: document.data())
                        print("Action: \(action)")
                        self.previousActions.append(action)
                        
                        if action.type == .swipeLeft {
                            // Get owner of post
                            let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(action.objectId)
                            postDocument.getDocument() { snapshot, error in
                                if let error = error {
                                    print(error)
                                }
                                if let snapshot = snapshot, let postData = snapshot.data() {
                                    let postModel = PostModel(from: postData, id: snapshot.documentID)
                                    self.swipeLeftUserIds.append(postModel.userId)
                                    self.savePreviousSwipeLeftUser(userId: postModel.userId)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func savePreviousSwipeLeftUser(userId: String) {
        
        if var previousSwipeLeftUsers = UserDefaults.standard.stringArray(forKey: "previousActions") {
            previousSwipeLeftUsers.append(userId)
            UserDefaults.standard.setValue(previousSwipeLeftUsers, forKey: "previousActions")
        } else {
            UserDefaults.standard.setValue([userId], forKey: "previousActions")
        }
    }
}
