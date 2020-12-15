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
    var posts: [PostModel] = []

    // id - PostCell data dictionary
    var postCellData = [String: PostCellContentData]()
    
    struct PostData {
        let id: String
        let username: String
        let content: [String]?
        let imageRefs: [String]?
    }
    
    struct PostCellContentData {
        let profile: Profile
        let timestamp: Date
        let content: [String]?
        let images:[UIImage]?
    }
    
    func load(cell: ImagePostCell, indexRow: Int) {
        // if content is already loaded
        //   load content to cell
        // else
        //   load content to cell from backend
        
        cell.loadFromPost(post: posts[indexRow])
        
        postCellData[cell.postId!] = PostCellContentData(profile: cell.profile!, timestamp: Date(), content: ["This is a test post"], images: [UIImage(named:"charlizePost")!])
    }
    
    func loadFromId(indentifier: String) {
        
        //cell.loadFromData(profile: profile, timestamp: timestamp, content: content, images: images)
    }
    
    func refreshIds() {
        // Fetch posts, check if any id needs to be added/loaded (or removed)
    }
}
