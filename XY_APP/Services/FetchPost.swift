//
//  FetchPost.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import Firebase

class FetchPostService {
    static func fetchPostWithId(_ id: String, completion: @escaping(Result<PostData,Error>) -> Void) {
        // Get posts from backend
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).getDocuments(source: .default) { documentSnapshots, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let documentSnapshots = documentSnapshots {
                for doc in documentSnapshots.documents {
                    let data = doc.data()
                    let author = data["author"] as! String
                    
                    let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(author)
                    userDoc.getDocument { userdata, error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        
                        if let userdata = userdata {
                            let username = userdata["xyname"] as! String
                            let postData = data["postData"] as! NSMutableDictionary
                            let caption = postData["caption"] as! String
                            let imageRef = postData["imageRef"] as! String
                            let timestamp = postData["timestamp"] as! Firebase.Timestamp
                            
                            completion(.success(PostData(id: "", username: username, timestamp: Date(timeIntervalSince1970: TimeInterval(timestamp.seconds)), content: caption, images: [imageRef])))
                        }
                    }
                }
            } else { fatalError() }
        }
    }
}
