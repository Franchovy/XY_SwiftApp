//
//  XPCircle.swift
//  XY_APP
//
//  Created by Maxime Franchot on 10/01/2021.
//

import Foundation

protocol XPViewModelDelegate: NSObjectProtocol {
    func onProgress(level: Int, progress: Float)
}

class XPViewModel {
    // View model hides the data model from the view/controller
    var xpModel : XPModel
    weak var delegate : XPViewModelDelegate!
    
    init(userId: String) {
        xpModel = XPModel(type: .user, xp: 0, level: 0)
    }
    
    init(postId: String) {
        xpModel = XPModel(type: .post, xp: 0, level: 0)
    }
    
    // Subscribe to firebase model -> Calls protocol on update
    func subscribeToFirebase(documentId: String) {
        switch xpModel.type {
        case .post:
            let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(documentId)
            
            document.addSnapshotListener() { snapshot, error in
                if let error = error {
                    print("Error getting document for xp!")
                }
                guard let snapshot = snapshot else { fatalError("Invalid document id") }
                
                let data = snapshot.data()!
                let xp = data[FirebaseKeys.PostKeys.xp] as! Int
                let level = data[FirebaseKeys.PostKeys.level] as! Int
                
                // Send level update
            
                self.xpModel.xp = xp
                let nextLevelXP = XPModel.LEVELS[.post]![level]
                self.delegate.onProgress(level: level, progress: Float(xp) / Float(nextLevelXP))
            }
            
        case .user:
            break
        }
    }
    
    
    // func get xp data
    
    
    // func update display (progress)
}
