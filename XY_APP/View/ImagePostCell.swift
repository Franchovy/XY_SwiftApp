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
    
    var swipeRightGesture:UISwipeGestureRecognizer!
    var swipeLeftGesture:UISwipeGestureRecognizer!
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
        
        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(swipeGestureRecognizer:)))
        swipeRightGesture.direction = .right
        //addGestureRecognizer(swipeRightGesture)
        
        swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(swipeGestureRecognizer:)))
        swipeLeftGesture.direction = .left
        //addGestureRecognizer(swipeLeftGesture)
        
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
        // Load from data for this cell
        contentImageView.image = nil
        profileImageView.image = nil
        
    }
    
    var isSwipedRight = false
    var isSwipedLeft = false
    
    //
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {fatalError()}
        
        let velocity = gesture.velocity(in: nil)
        return abs(velocity.x) > abs(velocity.y)
    }
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: nil)
        
        postCard.transform.tx = translation.x
    }
    
    @objc func swipeLeft(swipeGestureRecognizer: UISwipeGestureRecognizer) {
        
        if !isSwipedLeft || isSwipedRight {
            isSwipedLeft = !isSwipedRight
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                if self.isSwipedRight {
                    self.transform.tx = 0
                } else {
                    self.transform = CGAffineTransform(translationX: -500, y: 0)
                }
            }, completion: { bool in
                if self.isSwipedRight {
                    self.isSwipedRight = false
                } else {
                    // Swipe left execution
                    print("swipe left!")
                }
            })
        }
    }
    
    @objc func swipeRight(swipeGestureRecognizer: UISwipeGestureRecognizer) {
        if !isSwipedRight || isSwipedLeft {
            isSwipedRight = !isSwipedLeft
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                if self.isSwipedLeft {
                    self.transform.tx = 0
                } else {
                    self.transform = CGAffineTransform(translationX: 150, y: 0)
                    
                    self.alpha = 0.5
                }
            }, completion: { bool in
                if self.isSwipedLeft {
                    self.isSwipedLeft = false
                } else {
                    // Swipe right execution
                    print("Swipe right!")
                }
            })
        } else if isSwipedRight {
            // Swipe right confirmation
            print("Confirm swipe right!")
            confirmSwipeRight()
        }
    }
    
    func confirmSwipeRight() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 20, options: .curveEaseIn, animations: {
            self.transform.tx = 300
        }, completion: { bool in
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                self.transform.tx = 0
            })
        })
    }
    
    enum SwipeDirection {
        case left
        case right
    }
    
    func removePostFromFlow(direction: SwipeDirection) {
        guard let flowVC = viewContainingController() as? FlowVC else {fatalError()}
            
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            self.transform.tx = 500
        }, completion: { bool in
            flowVC.barXPCircle.progressBarCircle.color = .blue
            
            // Collapse this view
            let indexPath = flowVC.tableView.indexPath(for: self)!
            //flowVC.removeCell()
            flowVC.data.remove(at: indexPath.row)
            flowVC.tableView.deleteRows(at: [indexPath], with: .right)
        })
    }
}

