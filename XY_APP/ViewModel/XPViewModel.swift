//
//  XPCircle.swift
//  XY_APP
//
//  Created by Maxime Franchot on 10/01/2021.
//

import Foundation
import Firebase

protocol XPViewModelDelegate: NSObjectProtocol {
    func onProgress(level: Int, progress: Float)
    func setProgress(level: Int, progress: Float)
}

class XPViewModel {
    // View model hides the data model from the view/controller
    var xpModel : XPModel
    weak var delegate : XPViewModelDelegate!
    
    init(type: XPLevelType) {
        xpModel = XPModel(type: type, xp: 0, level: 0)
    }
    
    // Subscribe to firebase model -> Calls protocol on update
    func subscribeToFirebase(documentId: String) {
        let document: DocumentReference
        
        switch xpModel.type {
        case .post:
            document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(documentId)
        case .user:
            document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(documentId)
        }
            
        document.addSnapshotListener() { snapshot, error in
            if let error = error {
                print("Error getting document for xp!")
            }
            guard let snapshot = snapshot, let data = snapshot.data() else { return }
            
            let xp: Int
            let level: Int
            
            switch self.xpModel.type {
            case .post:
                xp = data[FirebaseKeys.PostKeys.xp] as! Int
                level = data[FirebaseKeys.PostKeys.level] as! Int
            case .user:
                xp = data[FirebaseKeys.UserKeys.xp] as! Int
                level = data[FirebaseKeys.UserKeys.level] as! Int
            }
            
            // Send level update
        
            self.xpModel.xp = xp
            let nextLevelXP = XPModel.LEVELS[self.xpModel.type]![level]
            
            self.delegate.setProgress(level: level, progress: Float(xp) / Float(nextLevelXP))
        }
    }
    
    
    // func get xp data
    
    
    // func update display (progress)
}
