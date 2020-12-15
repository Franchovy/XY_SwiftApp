//
//  PictureLoader.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit

// Async class used by FlowTableView to store, and fetch images using async calls
class PictureLoader {
    static var cellImageDict = [String: UIImage]()
    
    static func fetchAndInsert(id:String, completion: @escaping(_ result: UIImage?) -> Void) {
        ImageManager.downloadImage(imageID: id, completion: { image in
            self.cellImageDict[id] = image
            
            completion(image)
        })
    }
    
    static func insert(id:String, image: UIImage) {
        cellImageDict[id] = image
    }
    
    static func get(id:String) -> UIImage? {
        return cellImageDict[id]
    }
}
