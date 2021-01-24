//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit
import FirebaseStorage
import AVFoundation

protocol ImagePostCellDelegate {
    func imagePostCellDelegate(didTapProfilePictureFor cell: ImagePostCell)
    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell)
    //TODO: swipe right, swipe left from flow.
}


class ImagePostCell: UITableViewCell, FlowDataCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var postCard: UIView!
    
    @IBOutlet weak var xpLevelDisplay: CircleView!
    
    @IBOutlet weak var nameLabelLeftConstraint: NSLayoutConstraint!
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
    @IBOutlet weak var captionAlphaView: GradientView!
    
    
    var isSwipedRightXPView = false
    static let defaultPanSensitivity = 0.05
    var panSensitivity = defaultPanSensitivity
    
    // MARK: - PROPERTIES
    
    static let nibName = "ImagePostCell"
    static let identifier = "imagePostCell"
    static var type: FlowDataType = .post
    var type: FlowDataType = .post
    
    // deprecate
    var delegate: ImagePostCellDelegate?
    
    var images: [UIImage]?
    
    var viewModel: PostViewModel! {
        didSet {
            // Set delegate so the viewModel can call to set images
            viewModel.delegate = self
            // Set data already ready
            FirebaseSubscriptionManager.shared.registerXPUpdates(for: viewModel.postId, ofType: .post) { [weak self] (xpModel) in
                
                guard let strongSelf = self, let nextLevelXP = XPModel.LEVELS[.post]?[xpModel.level] else {
                    return
                }
                
                strongSelf.xpLevelDisplay.onProgress(
                    level: xpModel.level,
                    progress: Float(xpModel.xp) / Float(nextLevelXP)
                )
            }
            
            xpLevelDisplay.setProgress(level: 1, progress: 0.5)
            
            contentLabel.text = viewModel.content
            timestampLabel.text = viewModel.getTimestampString()
            timestampLabel.sizeToFit()
        }
    }
    
    // MARK: - PostViewModel Delegate Methods
    
    func didFetchProfileImage() {
        profileImageView.image = viewModel?.profileImage
    }
    
    func didFetchPostImages() {
        contentImageView.image = viewModel?.images.first
    }
    
    func didFetchProfileData(xyname: String) {
        nameLabel.text = xyname
    }
    
    // MARK: - PUBLIC METHODS
    
    var panGesture:UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentImageView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = 5
        captionAlphaView.layer.cornerRadius = 15
        timestampLabel.alpha = 1
        nameLabel.alpha = 1
        contentLabel.alpha = 1
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGestureRecognizer:)))
        panGesture.delegate = self
        panGesture.isEnabled = true
        addGestureRecognizer(panGesture)
        
        profileImageView.isUserInteractionEnabled = true
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        tapProfileImage.delegate = self
        profileImageView.addGestureRecognizer(tapProfileImage)
    
    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        postCard.layer.shadowOpacity = 0.0
        postCard.transform.tx = 0
        contentImageView.image = nil
        profileImageView.image = nil
        contentLabel.text = ""
        nameLabel.text = ""
        
        FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: viewModel.postId)
        xpLevelDisplay.reset()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else { return true }
        
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.imagePostCellDelegate(didTapProfilePictureFor: self)
    }
    
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: nil)
        
        if postCard.transform.tx > 0 {
            postCard.layer.shadowColor = UIColor.green.cgColor
        } else {
            postCard.layer.shadowColor = UIColor.red.cgColor
        }
        
        postCard.layer.shadowOpacity = abs(Float(postCard.transform.tx / 150))
        
        postCard.transform.tx = postCard.transform.tx + translation.x * CGFloat(panSensitivity)
        
        if panGestureRecognizer.state == .ended {
            panSensitivity = ImagePostCell.defaultPanSensitivity
            
            // On pan release
            if translation.x > 0 {
                // Direction: Right
                if isSwipedRightXPView {
                    // Confirm Swipe Right
                    isSwipedRightXPView = false
                    confirmSwipe(direction: .right)
                }
                
                if panGestureRecognizer.velocity(in: nil).x > 150
                    && translation.x > 50 {
                    // Confirm swipe right
                    confirmSwipe(direction: .right)
                } else if translation.x < 30 {
                    // Cancel gesture
                    cancelSwipe()
                } else {
                    // XP Circle
                    swipeRightXPView()
                }
            } else {
                // Direction: Left
                if isSwipedRightXPView {
                    isSwipedRightXPView = false
                    panSensitivity = 1.0
                    cancelSwipe()
                } else {
                    // Swipe Left
                    if translation.x > -100 {
                        // Cancel gesture
                        cancelSwipe()
                    } else {
                        // Swipe Left
                        confirmSwipe(direction: .left)
                    }
                }
            }
        } else {
            // Transform while holding
            if isSwipedRightXPView && translation.x < 0 {
                isSwipedRightXPView = false
                cancelSwipe()
                return
            }
        }
    }
    
    func cancelSwipe() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.postCard.transform.tx = 0
            self.postCard.layer.shadowOpacity = 0.0
        }, completion: { bool in
            
        })
    }
    
    func swipeRightXPView() {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: .curveEaseIn, animations: {
            self.postCard.transform.tx = 150
            
            
        }, completion: { bool in
            self.isSwipedRightXPView = true
        })
        
    }
    
    enum SwipeDirection {
        case left
        case right
    }
    
    func confirmSwipe(direction: SwipeDirection) {
        let directionMultiplier = direction == .left ? -1 : 1
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 5.0, initialSpringVelocity: 20, options: .curveEaseIn, animations: {
            self.postCard.transform.tx = 500 * CGFloat(directionMultiplier)
            
        }, completion: { done in
            if done {
                
                if direction == .left {
                    UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                        self.postCard.transform.tx = 500 * CGFloat(directionMultiplier)
                    }, completion: { bool in
                        guard let flowVC = self.viewContainingController() as? FlowVC else { fatalError() }
                        
                        flowVC.barXPCircle.progressBarCircle.color = .blue
                        
                        // Collapse this view
                        let indexPath = flowVC.tableView.indexPath(for: self)!
                        
                        flowVC.data.remove(at: indexPath.row)
                        flowVC.tableView.deleteRows(at: [indexPath], with: direction == .right ? .right : .left)
                        
                        self.viewModel.sendSwipeLeft()
                    })
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 15, options: .beginFromCurrentState, animations: {
                        self.postCard.transform.tx = 0
                        self.postCard.layer.shadowOpacity = 0.0
                    }, completion: { done in
                        if done {
                            // Swipe Right to firebase
                            self.viewModel.sendSwipeRight()
                        }
                    })
                }
            }
        })
    }
}

extension ImagePostCell : PostViewModelDelegate {
    func profileImageDownloadProgress(progress: Float) {
        
    }
    
    func postImageDownloadProgress(progress: Float) {
        
    }
    
    
}
