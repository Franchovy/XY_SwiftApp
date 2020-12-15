//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit


class ImagePostCell: UITableViewCell {
    
    @IBOutlet weak var nameLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var postCardView: UIView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var profileImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageTopConstraint: NSLayoutConstraint!
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
        if let images = post.imageRefs, images.count > 0 {
            // Set post sizing and constraints for image post
            self.contentImageView.frame.size.height = 359
            self.contentImageViewHeightConstraint.constant = 359
            profileImageView.layer.cornerRadius = 5
            profileImageWidthConstraint.constant = 40
            profileImageHeightConstraint.constant = 40
            profileImageLeftConstraint.constant = 19
            profileImageTopConstraint.constant = 19
            nameLabelLeftConstraint.constant = 6
            cameraIcon.isHidden = false
            
        } else {
            // Set post sizing and constraints for text only post
            contentImageView.frame.size.height = 0
            contentImageViewHeightConstraint.constant = 0
            profileImageView.layer.cornerRadius = 5
            profileImageWidthConstraint.constant = 25
            profileImageHeightConstraint.constant = 25
            profileImageLeftConstraint.constant = 10
            profileImageTopConstraint.constant = 10
            nameLabelLeftConstraint.constant = 29
            cameraIcon.isHidden = true
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
        
        postCardView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        
        
    }
    
}
