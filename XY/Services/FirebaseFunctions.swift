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
        //functions.useEmulator(withHost: "http://0.0.0.0", port: 5001)
    }
    
    lazy var functions = Functions.functions()
    
    
    public func swipeRight(postId: String) {
        let swipeRightData = [
            "postId": postId,
            "swipeUserId": Auth.auth().currentUser!.uid
        ]
        
        print("Sending swipe right with data: \(swipeRightData)")
        functions.httpsCallable("swipeRightPost").call(swipeRightData) { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            print("Error in swipe Right response: \(error)")
          }
          if let responseData = result?.data as? [String: Any] {
            print("Successful! Response data: \(responseData)")
          }
        }
    }
}
