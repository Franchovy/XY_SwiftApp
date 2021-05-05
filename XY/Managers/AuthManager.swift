//
//  AuthManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import Firebase
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() { }
    
    var userId: String?
    var email: String?
    
    func isLoggedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser {
            userId = currentUser.uid
            email = currentUser.email
            
            return true
        } else {
            return false
        }
    }
    
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
    
    func logout() {
        do {
            try Auth.auth().signOut()
            
            UserDefaultsManager.shared.removeAll()
            CoreDataManager.shared.deleteEverything()
            
        } catch let error {
            print("Error logging out: \(error)")
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
    
    func login(withEmail email: String, password: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let uid = authResult?.user.uid else { fatalError() }
                self.userId = uid
                
                completion(.success(true))
            }
        }
    }
    
    enum CreateUserError : String, Error {
        case emailTaken
        case xynameTaken
        case xynameInvalid
        case noInvite
        case passwordTooShort
        case unknownError
        
        var message: String {
            switch self {
            case .emailTaken:
                return "Email already in use!"
            case .xynameTaken:
                return "XYName already in use!"
            case .noInvite:
                return "This email has not been invited!"
            case .xynameInvalid:
                return "This XYName is invalid"
            case .passwordTooShort:
                return "Please write a longer password"
            case .unknownError:
                return "Error Signing up"
            }
        }
    }
    
    func signUp(xyname: String, email: String, password: String, completion: @escaping(Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                if (error as! NSError).code == 17007 {
                    completion(.failure(CreateUserError.emailTaken))
                } else {
                    completion(.failure(error))
                }
            }
            
            guard let uid = authResult?.user.uid else {
                return
            }
            self.userId = uid
            self.email = email
            
            // Set user data in user firestore table after signup
            let newUserDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
            
            let newUserData: [String: Any] = [
                FirebaseKeys.UserKeys.xyname : xyname,
                FirebaseKeys.UserKeys.timestamp : FieldValue.serverTimestamp(),
            ]
            
            newUserDocument.setData(newUserData) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(uid))
            }
        }
    }
}
