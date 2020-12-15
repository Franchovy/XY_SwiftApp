//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit


class ImagePostCell: UITableViewCell {
    
    @IBOutlet weak var contentImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var postId: String?
    var profileImage:ProfileImage?
    var profile: Profile?
    
    // Load into view from data
    func loadFromData(profile: Profile, timestamp: Date, content: [String]?, images: [UIImage]?) {
        
    }
    
    // Load into view from post - calls to profile and images from backend
    func loadFromPost(post: PostModel) {
        // Load data for this post
        loadProfile(username: post.username, completion: {
            self.loadPicture()
        })
        
        postId = post.id
        
        // Refresh image
        //self.contentImageView.image = nil
        
        if let images = post.imageRefs, images.count > 0 {
            self.contentImageView.frame.size.height = 359
            self.contentImageViewHeightConstraint.constant = 359
        } else {
            contentImageView.frame.size.height = 0
            contentImageViewHeightConstraint.constant = 0
        }
        
        // Load UI data
        nameLabel.text = post.username
        contentLabel.text = post.content
        // Load images
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
        self.profile = user
        user.load(completion: { completion(()) })
    }
    
    func loadPicture() {
        if let profilePhotoId = profile?.profilePhotoId {
            // Get profile Image for this user
            profileImage = ProfileImage(user: profile!, imageId: profilePhotoId)
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
    
    override func prepareForReuse() {
        // Load from data for this cell
        
        
    }
    
}
