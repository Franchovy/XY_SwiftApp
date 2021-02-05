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
    
    /// Donwloads actions for this user, to be used for applications like posts or virals
    func getActions() {
        guard let userId = AuthManager.shared.userId else {
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
                    }
                }
            }
    }
}
