//
//  FirebaseFunctions.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation
import FirebaseFunctions

final class FirebaseFunctionsManager {
    static let shared = FirebaseFunctionsManager()
    
    private init() {
        functions.useEmulator(withHost: "http://0.0.0.0", port: 5001)
    }
    
    lazy var functions = Functions.functions()
    
    
    public func swipeRight(viralId: String) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let swipeRightData = [
            "viralId": viralId,
            "swipeUserId": userId
        ]
        
        functions.httpsCallable("swipeRightViral").call(swipeRightData) { (result, error) in
            if let error = error {
                print("Error swiping right on viral: \(error)")
                return
            } else if let result = result {
                print(result)
            }
        }
    }
    
    public func swipeLeft(viralId: String) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let swipeLeftData = [
            "viralId": viralId,
            "swipeUserId": userId
        ]
        
        functions.httpsCallable("swipeLeftViral").call(swipeLeftData) { (result, error) in
            if let error = error {
                print("Error swiping right on viral: \(error)")
                return
            } else if let result = result {
                print(result)
            }
        }
    }
    
    public func swipeRight(postId: String) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let swipeRightData = [
            "postId": postId,
            "swipeUserId": userId
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
        guard let userId = AuthManager.shared.userId else { return }
        
        let swipeLeftData = [
            "postId": postId,
            "swipeUserId": userId
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
        guard let userId = AuthManager.shared.userId else { return }
        
        functions.httpsCallable("checkUserLevelUp").call(["userId": userId]) { (_, error) in
            if let error = error {
                print("Error in checkLevelUp function call: \(error)")
            }
        }
    }
    
    
}
