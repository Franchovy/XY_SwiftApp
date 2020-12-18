//
//  PostLoader.swift
//  XY_APP
//
//  Created by Maxime Franchot on 15/12/2020.
//

import Foundation
import UIKit




class PostLoader {
    // Contains the posts in order of indexpath
    var posts: [Post] = []

    // id - PostCell data dictionary
    var postCellData = [String: PostCellData]()
    
    
    // MARK - DATA MODELS
    
    struct PostCellData {
        let profile: Profile
        let timestamp: Date
        let content: [String]?
        let images:[UIImage]?
    }
    
    func loadDataIntoCell(cell: ImagePostCell, indexRow: Int) {
        cell.loadFromPost(post: posts[indexRow])
    }
}
