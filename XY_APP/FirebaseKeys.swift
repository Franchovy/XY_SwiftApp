//
//  FirebaseKeys.swift
//  XY_APP
//
//  Created by Maxime Franchot on 04/01/2021.
//

import Firebase

struct FirebaseKeys {
    
    struct CollectionPath {
        ///Defining the collection path for each of these
        
        static let users = "users"
        
        static let posts = "Posts"
        
        static let conversations = "conversations"
        static let messages = "messages"
        static let senderField = "senderField"
        static let bodyField = "bodyField"
        static let dateField = "dateField"
    }
}
