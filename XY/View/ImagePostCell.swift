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
    func imagePostCellDelegate(didTapProfilePictureForProfile profileId: String)
    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell)
    //TODO: swipe right, swipe left from flow.
    func imagePostCellDelegate(willSwipeLeft cell: ImagePostCell)
    func imagePostCellDelegate(willSwipeRight cell: ImagePostCell)
    func imagePostCellDelegate(didSwipeLeft postId: String)
    func imagePostCellDelegate(didSwipeRight postId: String)
}


class ImagePostCell: UITableViewCell, FlowDataCell {
    
    // MARK: - PROPERTIES
    
    static let identifier = "imagePostCell"
    static var type: FlowDataType = .post
    var type: FlowDataType = .post

    var viewModel: PostViewModel?
        
    private var postCard: UIView = {
        let postCard = UIView()
        postCard.layer.cornerRadius = 15
        postCard.layer.masksToBounds = false
        // Normal shadow
        postCard.layer.shadowOpacity = 1.0
        postCard.layer.shadowColor = UIColor.black.cgColor
        postCard.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        postCard.layer.shadowRadius = 3.0
        return postCard
    }()
    
    private var postShadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowOpacity = 0.0
        shadowLayer.shadowOffset = CGSize(width: 0, height: 6)
        shadowLayer.shadowRadius = 8
        return shadowLayer
    }()
    
    private var xpCircle = CircleView()
    
    private var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let profileImageContainer = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let captionContainer = UIView()
    private let caption: MessageView = {
        let caption = MessageView()
        caption.clipsToBounds = true
        return caption
    }()
        
    var isSwipedRightXPView = false
    static let defaultPanSensitivity = 0.05
    var panSensitivity = defaultPanSensitivity
    var isSwiping = false
    
    // deprecate
    var delegate: ImagePostCellDelegate?
    
    var images: [UIImage]?
    
    var panGesture:UIPanGestureRecognizer!
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        
        addSubview(postCard)
        postCard.addSubview(contentImageView)
        postCard.layer.insertSublayer(postShadowLayer, at: 0)
        
        postCard.addSubview(xpCircle)
        
        caption.setColor(.blue)
        captionContainer.addSubview(caption)
        addSubview(captionContainer)
        
        profileImageContainer.addSubview(profileImageView)
        addSubview(profileImageContainer)
        
        postShadowLayer.path = UIBezierPath(roundedRect: postCard.bounds, cornerRadius: 15).cgPath
        postShadowLayer.shadowPath = postShadowLayer.path

        postShadowLayer.shadowRadius = 6
        postShadowLayer.shadowOffset = CGSize(width: 0, height: 8)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGestureRecognizer:)))
        panGesture.delegate = self
        panGesture.isEnabled = true
        addGestureRecognizer(panGesture)
        
        profileImageView.backgroundColor = .gray
        profileImageView.isUserInteractionEnabled = true
        
        contentView.isUserInteractionEnabled = false
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        tapProfileImage.delegate = self
        profileImageContainer.addGestureRecognizer(tapProfileImage)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let postCardSize = contentView.width - 34

        if !isSwiping {
            postCard.frame = CGRect(
                x: (contentView.width/2 - postCardSize/2),
                y: 10,
                width: postCardSize,
                height: postCardSize
            )
            
            xpCircle.frame = CGRect(
                x: postCard.width - 30 - 10.78,
                y: 10.78,
                width: 30,
                height: 30
            )
        }
        contentImageView.frame = postCard.bounds
    
        let postCardPos = postCardSize + 10
        
        profileImageContainer.frame = CGRect(
            x: (contentView.width/2 - postCardSize/2),
            y: postCardPos + 5,
            width: 50,
            height: 50
        )
        profileImageView.frame = profileImageContainer.bounds
        profileImageView.applyshadowWithCorner(
            containerView: profileImageContainer,
            cornerRadious: profileImageContainer.width / 2,
            shadowOffset: CGSize(width: 0.5, height: 0.5),
            shadowRadius: 2
        )
        
        let captionSize = caption.getSize()
        captionContainer.frame = CGRect(
            x: profileImageContainer.right + 14 ,
            y: postCardPos + 6,
            width: captionSize.width,
            height: captionSize.height
        )
        caption.layoutSubviews()
        caption.applyshadowWithCorner(
            containerView: captionContainer,
            cornerRadious: caption.layer.cornerRadius,
            shadowOffset: CGSize(width: 0.5, height: 0.5),
            shadowRadius: 1
        )
        caption.frame = captionContainer.bounds
        
        postShadowLayer.path = UIBezierPath(roundedRect: postCard.bounds, cornerRadius: 15).cgPath
        postShadowLayer.shadowPath = postShadowLayer.path

    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        postShadowLayer.shadowOpacity = 0.0
        postCard.transform = CGAffineTransform.identity
        
        contentImageView.image = nil
        profileImageView.image = nil
        caption.text = ""
        
        if let viewModel = viewModel {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: viewModel.postId)
        }
        xpCircle.reset()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else { return true }
        
    }

    // MARK: - Obj-C Functions
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let profileId = viewModel?.profileId else {
            return
        }
        delegate?.imagePostCellDelegate(didTapProfilePictureForProfile: profileId)
    }
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translationX = panGestureRecognizer.translation(in: contentView).x
        let velocityX = panGestureRecognizer.velocity(in: contentView).x
        
        let transform = CGAffineTransform(
            translationX: translationX,
            y: 0
        )
        
        isSwiping = true
        
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
            
            guard let delegate = self.delegate, let viewModel = self.viewModel else {
                return
            }
            delegate.imagePostCellDelegate(willSwipeRight: self)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.postCard.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            } completion: { (done) in
                if done {
                    // Swipe Right
                    delegate.imagePostCellDelegate(didSwipeRight: viewModel.postId)
                    
                    self.isSwiping = false
                }
            }
        } else if translationX < -50, velocityX < -10 {
            
            guard let delegate = self.delegate, let viewModel = self.viewModel else {
                return
            }
            delegate.imagePostCellDelegate(willSwipeLeft: self)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.postCard.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
                
            } completion: { (done) in
                if done {
                    // Swipe Left
                    delegate.imagePostCellDelegate(didSwipeLeft: viewModel.postId)
                    self.isSwiping = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                self.postCard.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
                self.postShadowLayer.shadowOpacity = 0
                self.isSwiping = false
            }
        }
    }
    
    // MARK: - Public functions
    
    public func configure(with viewModel: PostViewModel) {
        viewModel.delegate = self
        self.viewModel = viewModel
        
        contentImageView.image = viewModel.images.first
        profileImageView.image = viewModel.profileImage
        
        caption.text = viewModel.content
        caption.timestamp = viewModel.getTimestampString()

        guard viewModel.postId != "" else {
            return
        }
        
        FirebaseSubscriptionManager.shared.registerXPUpdates(for: viewModel.postId, ofType: .post) { [weak self] (xpModel) in
            
            guard let strongSelf = self, let nextLevelXP = XPModel.LEVELS[.post]?[xpModel.level] else {
                return
            }
            
            strongSelf.xpCircle.onProgress(
                level: xpModel.level,
                progress: Float(xpModel.xp) / Float(nextLevelXP)
            )
        }
        
        xpCircle.setProgress(level: 0, progress: 0.0)
        xpCircle.setupFinished()
    }
    
    func setHeroId(_ id: String) {
//        contentImageView.heroID = "batman"
    }
    
}


// MARK: - PostViewModel Delegate

extension ImagePostCell : PostViewModelDelegate {
    func didFetchProfileData(viewModel: PostViewModel) {
        caption.name = viewModel.nickname
    }
    
    func didFetchProfileImage(viewModel: PostViewModel) {
        profileImageView.image = viewModel.profileImage
    }
    
    func didFetchPostImages(viewModel: PostViewModel) {
        contentImageView.image = viewModel.images.first
    }
}
