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
        // if cell.profile is not loaded
        //   load profile
        
        // if content is already loaded
        //   load content to cell
        // else
        //   load content to cell from backend
        
        cell.loadFromPost(post: posts[indexRow])
        
        postCellData[cell.postId!] = PostCellData(profile: cell.profile!, timestamp: Date(), content: ["This is a test post"], images: [UIImage(named:"charlizePost")!])
    }
}
