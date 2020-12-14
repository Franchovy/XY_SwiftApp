//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit

class ImagePostCell: UITableViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
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
                // Load a single image
                self.contentImageView.image = images.first
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
