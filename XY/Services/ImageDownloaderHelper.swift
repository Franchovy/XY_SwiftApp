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
    
    var cachedImageURLs = [String: URL]()
    
    func getFullURL(imageId: String, completion: @escaping(URL?, Error?) -> Void) {
        if let cachedImageURL = cachedImageURLs[imageId] {
            print("Returning cached image")
            completion(cachedImageURL, nil)
        } else {
            let storage = Storage.storage()
            let ref = storage.reference(withPath: imageId)
            ref.downloadURL() { url, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                
                if let url = url {
                    self.cachedImageURLs[imageId] = url
                }
                
                completion(url, nil)
                
            }
        }
    }
}
