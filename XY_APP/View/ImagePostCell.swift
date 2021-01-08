//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit
import FirebaseStorage

class ImagePostCell: UITableViewCell, FlowDataCell, PostViewModelDelegate {
    
    // MARK: - PROPERTIES
    
    var images: [UIImage]?
    
    var type: FlowDataType = { return .post }()
    
    var viewModel: PostViewModel! {
        didSet {
            // Set delegate so the viewModel can call to set images
            viewModel.delegate = self
            // Set data already ready
            contentLabel.text = viewModel.content
            timestampLabel.text = viewModel.getTimestampString()
        }
    }
    
    static let nibName = "ImagePostCell"
    static let identifier = "imagePostCell"
    
    // MARK: - PostViewModel Delegate Methods
    
    func didFetchProfileImage(image: UIImage) {
        profileImageView.image = viewModel?.profileImage
    }
    
    func didFetchPostImages(images: [UIImage]) {
        contentImageView.image = viewModel?.images.first
    }
    
    func didFetchProfileData(xyname: String) {
        nameLabel.text = xyname
    }
    
    // MARK: - IBOutlets
    
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
    
    // MARK: - PUBLIC METHODS
    
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

