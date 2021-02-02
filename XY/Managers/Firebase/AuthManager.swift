//
//  AuthManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    func verifyPassword(password: String, completion: @escaping(Bool?, Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                if error.localizedDescription.contains("The password is invalid or the user does not have a password.") {
                    completion(false, nil)
                } else {
                    completion(nil, error)
                }
            } else if let result = result {
                completion(true, nil)
            }
        }
    }
    
    func changePassword(newPassword: String, completion: @escaping(Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        user.updatePassword(to: newPassword) { (error) in
            completion(error)
        }
    }
}
