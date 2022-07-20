//
//  FirebaseFunctions.swift
//  XY
//
//  Created by Maxime Franchot on 19/01/2021.
//

import Foundation
import FirebaseFunctions
import Firebase

final class FirebaseFunctionsManager {
    static let shared = FirebaseFunctionsManager()
    
    private init() {
//        functions.useEmulator(withHost: "http://0.0.0.0", port: 5001)
    }
    
    lazy var functions = Functions.functions()
    
    public func register(email: String, xyname: String, password: String, completion: @escaping(Result<HTTPSCallableResult?, Error>) -> Void) {
        let registerData = [
            "email": email,
            "xyname": xyname,
            "password": password
        ]
        
        completion(.success(nil))
        /*
        functions.httpsCallable("register").call(registerData) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
            
        }*/
    }
    
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
    
    public func checkUserLevelUp() {
        guard let userId = AuthManager.shared.userId else { return }
        
        functions.httpsCallable("checkUserLevelUp").call(["userId": userId]) { (_, error) in
            if let error = error {
                print("Error in checkLevelUp function call: \(error)")
            }
        }
    }
    
    public func getFlow(swipeLeftIds: [String], algorithmIndex: Int, completion: @escaping([PostModel]?) -> Void) {
        guard let userId = AuthManager.shared.userId else { return }

        let data:[String: Any] = [
            "userId": userId,
            "swipeLeftItems": swipeLeftIds,
            "algorithmIndex": algorithmIndex
        ]
        
        functions.httpsCallable("getFlow").call(data) { result, error in
            if let error = error {
                print("Error fetching flow: \(error)")
                completion(nil)
            } else if let data = result?.data as? [String: Any] {
                if let postsData = data["postModels"] as? [[String: Any]] {
                    let postModels:[PostModel] = postsData.compactMap({ postData in
                        let postDataData = postData[FirebaseKeys.PostKeys.postData] as! [String: Any]
                        
                        return PostModel(
                            id: postData["id"] as! String,
                            userId: postData[FirebaseKeys.PostKeys.author] as! String,
                            timestamp: TimestampDecoder.decode(data: (postData[FirebaseKeys.PostKeys.timestamp] as! [String: Any])),
                            content: postDataData[FirebaseKeys.PostKeys.PostData.caption] as? String ?? "",
                            images: [postDataData[FirebaseKeys.PostKeys.PostData.imageRef] as! String],
                            level: postData[FirebaseKeys.PostKeys.level] as! Int,
                            xp: postData[FirebaseKeys.PostKeys.xp] as! Int
                        )
                    })
                    
                    completion(postModels)
                }
                
            }
        }
    }
}

class TimestampDecoder {
    static func decode(data: [String: Any]) -> Date {
        if let numSeconds = data["_seconds"] as? Int {
            return Date(timeIntervalSince1970: Double(numSeconds))
        } else {
            fatalError()
        }
    }
}
