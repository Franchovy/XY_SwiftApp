//
//  FirebaseFunctions.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation
import FirebaseAuth
import FirebaseFunctions

final class FirebaseFunctionsManager {
    static let shared = FirebaseFunctionsManager()
    
    private init() {
//        functions.useEmulator(withHost: "http://0.0.0.0", port: 5001)
    }
    
    lazy var functions = Functions.functions()
    
    
    public func swipeRight(postId: String) {
        let swipeRightData = [
            "postId": postId,
            "swipeUserId": Auth.auth().currentUser!.uid
        ]
        
        functions.httpsCallable("swipeRightPost").call(swipeRightData) { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            print("Error in swipe Right response: \(error)")
          } else if let result = result {
            print(result)
            // On success
            self.checkPostLevelUp(postId: postId)
          }
        }
    }
    
    public func swipeLeft(postId: String) {
        let swipeLeftData = [
            "postId": postId,
            "swipeUserId": Auth.auth().currentUser!.uid
        ]
        
        functions.httpsCallable("swipeLeftPost").call(swipeLeftData) { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            print("Error in swipe Left response: \(error)")
          } else if let result = result {
            print(result)
          }
        }
    }
    
    public func checkPostLevelUp(postId: String) {
        functions.httpsCallable("checkPostLevelUp").call(["postId": postId]) { (_, error) in
            if let error = error {
                print("Error in checkLevelUp function call: \(error)")
            }
        }
    }
    
    public func checkUserLevelUp() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        functions.httpsCallable("checkUserLevelUp").call(["userId": userId]) { (_, error) in
            if let error = error {
                print("Error in checkLevelUp function call: \(error)")
            }
        }
    }
    
    
}
