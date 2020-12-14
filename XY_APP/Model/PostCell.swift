//
//  PostViewCell.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/12/2020.
//

import Foundation
import UIKit


class PostCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contentVStack: UIStackView!
    
    var profileImage:ProfileImage?
    var user: Profile?
    
    func loadFromPost(post: PostModel) {
        // Load data for this post
        loadProfile(username: post.username, completion: {
            self.loadPicture()
        })
        
        // Load UI data
        nameLabel.text = post.username
        contentLabel.text = post.content
        
        post.loadPhotos(completion: {images in
            // Load images if there are any ready
            if images.count > 0 {
                for image in images {
                    self.contentVStack.addSubview(UIImageView(image: image))
                }
            }
        })
    }
    
    func loadProfile(username:String, completion: @escaping(()) -> Void?) {
        // Create a new profile
        let user = Profile()
        // Set username and get profile info
        user.username = username
        self.user = user
        user.load(completion: { completion(()) })
    }
    
    func loadPicture() {
        if let profilePhotoId = user?.profilePhotoId {
            // Get profile Image for this user
            profileImage = ProfileImage(user: user!, imageId: profilePhotoId)
            profileImage?.load({ image in
                self.profileImage?.image = image
                self.profileImageView.image = image
            })
        } else {
            fatalError("Call loadProfile(username) before calling loadPicture.")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        contentView.backgroundColor = #colorLiteral(red: 0.05398157984, green: 0.05899176747, blue: 0.06317862123, alpha: 1)
        
        
        
        // set the text from the data model
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.white
        nameLabel.textColor = UIColor.white
        
        // add border and color
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 15
        clipsToBounds = true
    }
}
