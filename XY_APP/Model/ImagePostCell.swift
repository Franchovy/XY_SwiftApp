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
    
    // MARK: - UNREUSABLE PROPERTIES --- PLEASE CHANGE
    
    var postId: String?
    var profileImage:Profile.ProfileImage?
    var profile: Profile?
    
    // MARK: - PUBLIC METHODS
    
    // Load into view from post - calls to profile and images from backend
    func loadFromPost(post: Post) {
        // Load data for this post
        loadProfile(username: post.username, closure: { result in
            switch result {
            case .success(let profileData):
                if let profilePhotoId = profileData.profilePhotoId {
                    // Get profile Image for this user
                    self.profileImage = Profile.ProfileImage(user: self.profile!, imageId: profilePhotoId)
                    
                    
                    ImageCache.createOrQueueImageRequest(id: profilePhotoId, completion: { image in
                        if let image = image {
                            self.profileImage?.image = image

                            self.profileImageView.image = image
                        }
                    })
                    
//                    ImageCache.getOrFetch(id: profilePhotoId, closure: { result in
//                        switch result {
//                        case .success(let image):
//                            self.profileImage?.image = image
//
//                            DispatchQueue.main.async {
//                                self.profileImageView.image = image
//                            }
//                        case .failure(let error):
//                            print("Could not load profile image due to \(error)")
//                        }
//                    })
                } else {
                    fatalError("Call loadProfile(username) before calling loadPicture.")
                }
            case .failure(let error):
                print("Error loading profile for post: \(error)")
            }
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
        timestampLabel.text = getTimestampDisplay(date: post.timestamp)
        
        // Load images
        
        
        if let imgId = post.imageRefs?.first {
            ImageCache.createOrQueueImageRequest(id: imgId, completion: { image in
                
                if let image = image {
                    // Image formatting to fit properly
                    let resizingFactor = 200 / image.size.height
                    let newImage = UIImage(cgImage: image.cgImage!, scale: image.scale / resizingFactor, orientation: .up)
                    
                    
                    if post.images == nil {post.images = [UIImage]()}
                    
                    // Add image to loaded post images
                    post.images!.append(newImage)
                    
                    // Run completion handler once all images are downloaded
                    if post.images!.count == post.imageRefs!.count {
                        self.contentImageView.image = post.images?.first
                    }
                }
            })
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
