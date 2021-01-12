//
//  PostCells.swift
//  XY_APP
//
//  Created by Simone on 13/12/2020.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ImagePostCell: UITableViewCell, FlowDataCell, PostViewModelDelegate {
    func profileImageDownloadProgress(progress: Float) {
        
    }
    
    func postImageDownloadProgress(progress: Float) {
        
    }
    
    // MARK: - PROPERTIES
    
    var images: [UIImage]?
    
    var type: FlowDataType = { return .post }()
    
    var viewModel: PostViewModel! {
        didSet {
            // Set delegate so the viewModel can call to set images
            viewModel.delegate = self
            // Set data already ready
            xpLevelDisplay.viewModel = XPViewModel(type: .post)
            xpLevelDisplay.viewModel.subscribeToFirebase(documentId: viewModel.postId)
            contentLabel.text = viewModel.content
            timestampLabel.text = viewModel.getTimestampString()
        }
    }
    
    static let nibName = "ImagePostCell"
    static let identifier = "imagePostCell"
    
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
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var postCard: UIView!
    
    @IBOutlet weak var xpLevelDisplay: CircleView!
    
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
    
    var panGesture:UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentImageView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = 5
        postCardView.layer.cornerRadius = 15
        timestampLabel.alpha = 1
        nameLabel.alpha = 1
        contentLabel.alpha = 1
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGestureRecognizer:)))
        panGesture.delegate = self
        
        panGesture.isEnabled = true
        addGestureRecognizer(panGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        print("Prepare cell for reuse: \(viewModel!.postId!)")
        // Load from data for this cell
        contentImageView.image = nil
        profileImageView.image = nil
        xpLevelDisplay.reset()
    }
    
    //
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else { return true }
        
    }
    
    var isSwipedRightXPView = false
    static let defaultPanSensitivity = 2.3
    var panSensitivity = defaultPanSensitivity
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: nil)
        
        postCard.transform.tx = postCard.transform.tx + translation.x * CGFloat(panSensitivity)
        
        if panGestureRecognizer.state == .ended {
            panSensitivity = ImagePostCell.defaultPanSensitivity
            
            // On pan release
            if translation.x > 0 {
                // Direction: Right
                if isSwipedRightXPView {
                    // Confirm Swipe Right
                    isSwipedRightXPView = false
                    print("Confirm swipe right")
                    confirmSwipe(direction: .right)
                }
                
                if panGestureRecognizer.velocity(in: nil).x > 150
                    && translation.x > 50 {
                    // Confirm swipe right
                    confirmSwipe(direction: .right)
                    print("Direct swipe right")
                } else if translation.x < 30 {
                    // Cancel gesture
                    cancelSwipe()
                    print("Cancel swipe")
                } else {
                    // XP Circle
                    swipeRightXPView()
                    print("Swipe Right XP View")
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
            } else {
                if #available(iOS 13.0, *) {
                    
                    let PI = CGFloat(3.1415)
                    let sensitivity = CGFloat(0.001)
                    let angle = (translation.x * sensitivity * PI / 2) - PI / 2
                    
                    postCard.transform3D.m11 = -sin(angle)
                    postCard.transform3D.m12 = cos(angle)
                    postCard.transform3D.m31 = sin(angle)
                    postCard.transform3D.m32 = cos(angle)
                    postCard.transform3D.m23 = 1
                    postCard.transform3D.m44 = 1
                }
            }
        }
    }
    
    func cancelSwipe() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.postCard.transform.tx = 0
            
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
            
        }, completion: { bool in
            if direction == .left {
                UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                    self.postCard.transform.tx = 500 * CGFloat(directionMultiplier)
                }, completion: { bool in
                    guard let flowVC = self.viewContainingController() as? FlowVC else {fatalError()}
                    
                    flowVC.barXPCircle.progressBarCircle.color = .blue
                    
                    // Collapse this view
                    let indexPath = flowVC.tableView.indexPath(for: self)!
                    
                    flowVC.data.remove(at: indexPath.row)
                    flowVC.tableView.deleteRows(at: [indexPath], with: direction == .right ? .right : .left)
                })
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
                    self.postCard.transform.tx = 0
                }, completion: { bool in
                    // Swipe Right to firebase
                    self.viewModel.sendSwipeRight()
                })
            }
        })
    }
}

