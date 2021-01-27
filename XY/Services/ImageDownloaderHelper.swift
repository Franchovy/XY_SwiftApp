//
//  ImageDownloaderHelper.swift
//  XY_APP
//
//  Created by Maxime Franchot on 09/01/2021.
//

import Foundation
import FirebaseStorage

class ImageDownloaderHelper {
    static var shared = ImageDownloaderHelper()
    private init() { }
        
    func getFullURL(imageId: String, completion: @escaping(URL?, Error?) -> Void) {
        let storage = Storage.storage()
        let ref = storage.reference(withPath: imageId)
        print("Fetching image: \(imageId)")
        ref.downloadURL() { url, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(url, nil)
        }
    }
}
