//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit


class ImagePostCell: UITableViewCell, FlowDataCell {
    var type: FlowDataType = { return .post }()
    
    @IBOutlet weak var XP: CircleView!
    
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
    @IBOutlet weak var captionAlphaView: UIView!
    
    
    
    // MARK: - PROPERTIES
    
    //TODO: Link up to XYImage, XYProfileImage, XYPost classes
    
    var images: [UIImage]?
    
    var profileImage:Profile.ProfileImage?
    var profile: Profile?
    
    var postId: String?
    
    // MARK: - PUBLIC METHODS
    
    // Load into view from post - calls to profile and images from backend
    func loadPostData(post: PostData) {
        
        // Get profile Image for this user
        if let imageId = post.profileImage {
                // Run fetch in background thread
            DispatchQueue.global(qos: .background).async {
                ImageCache.createOrQueueImageRequest(id: imageId) { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            self.profileImageView.image = image
                        }
                    }
                }
            }
        }
        
        // Load UI data
        nameLabel.text = post.username
        contentLabel.text = post.content
        timestampLabel.text = getTimestampDisplay(date: post.timestamp)
        
        // Load images
        if let images = post.images {
            for imageId in images {
                // Run fetch in background thread
                DispatchQueue.global(qos: .background).async {
                    ImageCache.createOrQueueImageRequest(id: imageId) { image in
                        if let image = image {
                            DispatchQueue.main.async {
                                self.contentImageView.image = image
                            }
                        }
                    }
                }
                return
            }
        }
    }
    
    func getTimestampDisplay(date: Date) -> String {
        return date.description
    }
    
    
    func loadProfile(username:String, closure: @escaping(Result<Profile.ProfileData, Profile.LoadProfileError>) -> Void) {
        // Create a new profile
        let user = Profile()
        // Set username and get profile info
        user.profileData?.username = username
        self.profile = user
        
        user.getProfile(username: username, closure: closure)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentImageView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = 5
        postCardView.layer.cornerRadius = 15
        timestampLabel.alpha = 1
        nameLabel.alpha = 1
        contentLabel.alpha = 1
        
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        
        
    }
    
}

