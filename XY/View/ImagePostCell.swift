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
    func imagePostCellDelegate(willSwipeLeft cell: ImagePostCell)
    func imagePostCellDelegate(willSwipeRight cell: ImagePostCell)
    func imagePostCellDelegate(didSwipeLeft cell: ImagePostCell)
    func imagePostCellDelegate(didSwipeRight cell: ImagePostCell)
}


class ImagePostCell: UITableViewCell, FlowDataCell {
    
    // MARK: - PROPERTIES
    
    static let nibName = "ImagePostCell"
    static let identifier = "imagePostCell"
    static var type: FlowDataType = .post
    var type: FlowDataType = .post
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var postCard: UIView!
    var postShadowLayer = CAShapeLayer()
    
    @IBOutlet weak var xpLevelDisplay: CircleView!
    
    @IBOutlet weak var contentImageView: UIImageView!
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    private let caption: MessageView = {
        let caption = MessageView()
        caption.clipsToBounds = true
        return caption
    }()
        
    var isSwipedRightXPView = false
    static let defaultPanSensitivity = 0.05
    var panSensitivity = defaultPanSensitivity
    
    // deprecate
    var delegate: ImagePostCellDelegate?
    
    var images: [UIImage]?
    
    weak var viewModel: PostViewModel?
    
    // MARK: - PostViewModel Delegate Methods
    
    func didFetchProfileImage() {
        profileImageView.image = viewModel?.profileImage
    }
    
    func didFetchPostImages() {
        contentImageView.image = viewModel?.images.first
    }
    
    func didFetchProfileData(xyname: String) {
//        nameLabel.text = xyname
        caption.name = xyname
    }
    
    // MARK: - PUBLIC METHODS
    
    var panGesture:UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(caption)
        addSubview(profileImageView)
        caption.setColor(.blue)
        
        postCard.layer.cornerRadius = 15
        
        contentImageView.layer.cornerRadius = 15
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGestureRecognizer:)))
        panGesture.delegate = self
        panGesture.isEnabled = true
        addGestureRecognizer(panGesture)
        
        profileImageView.backgroundColor = .gray
        profileImageView.isUserInteractionEnabled = true
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        tapProfileImage.delegate = self
        profileImageView.addGestureRecognizer(tapProfileImage)
        
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 5
    }
    
    override func layoutSubviews() {
        let contentWidth = min(contentView.width - 30, contentImageView.width)
        let contentHeight = contentImageView.height
        
        postCard.frame = CGRect(
            x: (contentView.width/2 - contentWidth/2),
            y: 10,
            width: contentWidth,
            height: contentHeight
        )
        
        profileImageView.frame = CGRect(
            x: postCard.left,
            y: postCard.bottom + 13,
            width: 40,
            height: 40
        )
        
        
        let captionSize = caption.getSize()
        caption.frame = CGRect(
            x: profileImageView.right + 14 ,
            y: postCard.bottom + 6,
            width: captionSize.width,
            height: captionSize.height
        )
        caption.setNeedsLayout()
        
        postShadowLayer.path = UIBezierPath(roundedRect: postCard.bounds, cornerRadius: 15).cgPath
        postShadowLayer.shadowPath = postShadowLayer.path

        postShadowLayer.shadowRadius = 6
        postShadowLayer.shadowOffset = CGSize(width: 0, height: 8)
        postCard.layer.insertSublayer(postShadowLayer, at: 0)
    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        postCard.layer.shadowOpacity = 0.0
        postCard.layer.shadowColor = UIColor.black.cgColor
        postCard.transform = CGAffineTransform.identity
        
        postShadowLayer.shadowOpacity = 0.0
        
        contentImageView.image = nil
        profileImageView.image = nil
        caption.text = ""
        
        if let viewModel = viewModel {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: viewModel.postId)
        }
        xpLevelDisplay.reset()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else { return true }
        
    }
    
    public func configure(with viewModel: PostViewModel) {
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
        
        caption.text = viewModel.content
        caption.timestamp = viewModel.getTimestampString()
        
        self.viewModel = viewModel
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.imagePostCellDelegate(didTapProfilePictureFor: self)
    }
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translationX = panGestureRecognizer.translation(in: contentView).x
        let velocityX = panGestureRecognizer.velocity(in: contentView).x
        
        let transform = CGAffineTransform(
            translationX: translationX,
            y: 0
        )
        
        postCard.transform = transform.rotated(by: translationX / 500)
        
        // Color for swipe
        if translationX > 0 {
            postShadowLayer.shadowColor = UIColor.green.cgColor
        } else {
            postShadowLayer.shadowColor = UIColor.red.cgColor
        }
        
        postShadowLayer.shadowOpacity = Float(abs(translationX) / 50)
        
        
        // On gesture finish
        guard panGestureRecognizer.state == .ended else {
          return
        }
        
        // Animate if needed
        if translationX > 50, velocityX > 10 {
            
            self.delegate?.imagePostCellDelegate(willSwipeRight: self)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.postCard.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            } completion: { (done) in
                if done {
                    // Swipe Right
                    self.delegate?.imagePostCellDelegate(didSwipeRight: self)
                }
            }
        } else if translationX < -50, velocityX < -10 {
            self.delegate?.imagePostCellDelegate(willSwipeLeft: self)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.postCard.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            } completion: { (done) in
                if done {
                    // Swipe Left
                    self.delegate?.imagePostCellDelegate(didSwipeLeft: self)
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                self.postCard.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
                self.postShadowLayer.shadowOpacity = 0
            }
        }
    }
    
    func cancelSwipe() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.postCard.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
            self.postCard.layer.shadowOpacity = 0.0
        }, completion: { bool in
            
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
                        
                        self.viewModel?.sendSwipeLeft()
                    })
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 15, options: .beginFromCurrentState, animations: {
                        self.postCard.transform.tx = 0
                        self.postCard.layer.shadowOpacity = 0.0
                    }, completion: { done in
                        if done {
                            // Swipe Right to firebase
                            self.viewModel?.sendSwipeRight()
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
