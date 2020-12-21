//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit


class ImagePostCell: UITableViewCell {
    
    @IBOutlet weak var XP: UIView!
   
    
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
    
    // MARK: - PROPERTIES
    
    var images: [UIImage]?
    var postId: String?
    var profileImage:Profile.ProfileImage?
    var profile: Profile?
    
    // MARK: - PUBLIC METHODS
    
    // Load into view from post - calls to profile and images from backend
    func loadFromPost(post: PostData) {
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
        if let images = post.images, images.count > 0 {
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
        
        
        if let imgId = post.images?.first {
            ImageCache.createOrQueueImageRequest(id: imgId, completion: { image in
                
                if let image = image {
                    // Image formatting to fit properly
                    let resizingFactor = 200 / image.size.height
                    let newImage = UIImage(cgImage: image.cgImage!, scale: image.scale / resizingFactor, orientation: .up)
                    
                    // Add image to loaded post images
                    if var images = self.images {
                        images.append(newImage)
                    } else {
                        self.images = [newImage]
                    }
                    
                    // Set contentImageView to this image
                    self.contentImageView.image = image
                } else {
                    print("Error loading image!")
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


@IBDesignable
class GradientCircularProgressBarPost: UIView {
    @IBInspectable var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var gradientColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var ringWidth: CGFloat = 5

    var progress: CGFloat = 1 {
        didSet { setNeedsDisplay() }
    }

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        createAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        createAnimation()
    }

    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(gradientLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
    }

    private func createAnimation() {
        let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        startPointAnimation.values = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]

        startPointAnimation.repeatCount = Float.infinity
        startPointAnimation.duration = 1

        let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
        endPointAnimation.values = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint.zero]

        endPointAnimation.repeatCount = Float.infinity
        endPointAnimation.duration = 1

        gradientLayer.add(startPointAnimation, forKey: "startPointAnimation")
        gradientLayer.add(endPointAnimation, forKey: "endPointAnimation")
    }

    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        createAnimation()
    }
}
