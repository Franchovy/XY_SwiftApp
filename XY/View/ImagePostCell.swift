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
    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell)
    //TODO: swipe right, swipe left from flow.
    func imagePostCellDelegate(willSwipeLeft cell: ImagePostCell)
    func imagePostCellDelegate(willSwipeRight cell: ImagePostCell)
    func imagePostCellDelegate(didSwipeLeft  cell: ImagePostCell)
    func imagePostCellDelegate(didSwipeRight  cell: ImagePostCell)
    func imagePostCellDelegate(reportPressed postId: String)
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
    
    private let reportButtonImage: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "exclamationmark.octagon.fill"), for: .normal)
        button.tintColor = .red
        button.alpha = 0
        return button
    }()
    
    private let reportButtonTitle: UIButton = {
        let button = UIButton()
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Report", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        button.alpha = 0
        return button
    }()
    
    private let loadingIcon = UIActivityIndicatorView()
    
    var isSwipedRightXPView = false
    static let defaultPanSensitivity = 0.05
    var panSensitivity = defaultPanSensitivity
    var isSwiping = false
    
    var delegate: ImagePostCellDelegate?
    
    var images: [UIImage]?
    
    var panGesture:UIPanGestureRecognizer!
    
    var tappedBackToCenterGesture = UITapGestureRecognizer()
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = UIColor(named: "Black")
        
        addSubview(reportButtonImage)
        addSubview(reportButtonTitle)
        
        addSubview(postCard)
        postCard.addSubview(loadingIcon)
        loadingIcon.startAnimating()
        
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
        
        tappedBackToCenterGesture = UITapGestureRecognizer(target: self, action: #selector(animateBackToCenter))
        tappedBackToCenterGesture.isEnabled = false
        postCard.addGestureRecognizer(tappedBackToCenterGesture)
        
        reportButtonImage.addTarget(self, action: #selector(reportPressed), for: .touchUpInside)
        reportButtonTitle.addTarget(self, action: #selector(reportPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let postCardSize = contentView.width - 34

        if postCard.transform == CGAffineTransform.identity {
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
        
        loadingIcon.frame.size = CGSize(width: 35, height: 35)
        loadingIcon.center = postCard.center
        
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
        
        
        if isSwiping {
            reportButtonImage.frame = CGRect(
                x: width/2 + 25,
                y: postCard.bottom - height/3,
                width: 30,
                height: 30
            )
            reportButtonTitle.sizeToFit()
            reportButtonTitle.frame = CGRect(
                x: reportButtonImage.left + (reportButtonImage.width - reportButtonTitle.width)/2,
                y: reportButtonImage.bottom + 5,
                width: reportButtonTitle.width,
                height: reportButtonTitle.height
            )
        }
    }
    
    override func prepareForReuse() {
        // Load from data for this cell
        postShadowLayer.shadowOpacity = 0.0
        postCard.transform = CGAffineTransform.identity
        caption.alpha = 1.0
        postCard.alpha = 1.0
        
        pauseTranslationX = 0
        didEndSwiping = false
        
        contentImageView.image = nil
        profileImageView.image = nil
        caption.text = ""
        caption.name = ""
        caption.timestamp = ""
        
        if let viewModel = viewModel {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: viewModel.postId)
        }
        xpCircle.reset()
        
        viewModel = nil
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
        profileImageView.heroID = "profileImage"
        
        guard let profileId = viewModel?.profileId else {
            return
        }
        ProfileManager.shared.openProfileForId(profileId)
    }
    
    var pauseTranslationX:CGFloat = 0
    var startPoint: CGFloat = 0
    var endPoint: CGFloat = 400
    var didBeginSwiping = false
    var didEndSwiping = false
    
    @objc func panGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        if didEndSwiping { return }
        
        // Swipe Begin
        if !didBeginSwiping {
            didBeginSwiping = true
            isSwiping = true
            
            startPoint = panGestureRecognizer.location(in: contentView).x
            print("Start point: \(startPoint)")
            onBeginSwiping()
        }
        
        var distance:CGFloat!
        var swipeProgress:CGFloat!
        
        let translationX = panGestureRecognizer.translation(in: contentView).x + pauseTranslationX
        let velocityX = panGestureRecognizer.velocity(in: contentView).x
        
        if translationX > 0 {
            // Rightward Movement
            endPoint = width - 40
            distance = endPoint - startPoint
            swipeProgress = translationX / distance
        } else {
            // Leftward Movement
            endPoint = 40
            distance = endPoint - startPoint
            swipeProgress = translationX / distance
        }
        
        // During Swipe Translate
        let directionMultiplier:CGFloat = translationX > 0 ? 1 : -1
        postCard.transform = CGAffineTransform(translationX: distance * (sqrt(swipeProgress)), y: 0).rotated(by: directionMultiplier * sqrt(swipeProgress)/5)
        if translationX > 0 {
            postShadowLayer.shadowColor = UIColor.green.cgColor
        } else {
            postShadowLayer.shadowColor = UIColor.red.cgColor
        }
        postShadowLayer.shadowOpacity = Float(swipeProgress)
        
        // On Swipe Finish
        if swipeProgress > 1 {
            onEndSwiping()
            animateConfirm() {
                if translationX > 0 {
                    self.animateSwipeRight()
                } else {
                    self.animateSwipeLeft()
                }
            }
        } else if panGestureRecognizer.state == .ended {
            animateBackToCenter()
            
            onEndSwiping(canceled: true)
        }
    }
    
    private func onBeginSwiping() {
        isSwiping = true
        superview?.bringSubviewToFront(self)
    }
    
    private func onEndSwiping(canceled: Bool = false) {
        isSwiping = false
        didBeginSwiping = false
        didEndSwiping = !canceled
    }
    
    private func animateConfirm(completion: @escaping(() -> Void)) {
        let originalTransform = postCard.transform

        HapticsManager.shared.vibrate(for: .success)
        
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn) {
            self.postCard.transform = originalTransform.scaledBy(x: 1.2, y: 1.2)
        } completion: { (done) in
            if done {
                
                UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseOut) {
                    self.postCard.transform = originalTransform
                } completion: { (done) in
                    if done {
                        completion()
                    }
                }
            }
        }
    }
    
    private func animateSwipeRight() {
        guard let delegate = self.delegate, let viewModel = self.viewModel else {
            return
        }
        delegate.imagePostCellDelegate(willSwipeRight: self)
        
        let currentTransform = postCard.transform
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.postCard.transform = currentTransform.translatedBy(x: 400, y: 200)
            self.postCard.rotate(numRotations: 3)
        } completion: { (done) in
            if done {
                // Swipe Right
                self.postCard.stopRotating()
                self.postCard.alpha = 0.0
                delegate.imagePostCellDelegate(didSwipeRight: self)
                self.reportButtonImage.alpha = 0.0
                self.reportButtonTitle.alpha = 0.0
                self.isSwiping = false
            }
        }
    }
    
    private func animateSwipeLeft() {
        guard let delegate = self.delegate, let viewModel = self.viewModel else {
            return
        }
        delegate.imagePostCellDelegate(willSwipeLeft: self)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            self.postCard.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            self.postCard.alpha = 0.0
        } completion: { (done) in
            if done {
                // Swipe Left
                delegate.imagePostCellDelegate(didSwipeLeft: self)
                self.reportButtonImage.alpha = 0.0
                self.reportButtonTitle.alpha = 0.0
                self.isSwiping = false
            }
        }
    }
    
    // MARK: - Private functions
    
    @objc private func reportPressed() {
        guard let postId = viewModel?.postId else {
            return
        }
        delegate?.imagePostCellDelegate(reportPressed: postId)
    }
    
    @objc private func animateBackToCenter() {
        pauseTranslationX = 0
        tappedBackToCenterGesture.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) {
            self.postCard.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
            self.reportButtonImage.alpha = 0.0
            self.reportButtonTitle.alpha = 0.0
            self.postShadowLayer.shadowOpacity = 0
            self.isSwiping = false
        }
    }
    
    // MARK: - Public functions
    
    public func configure(with viewModel: PostViewModel) {
        viewModel.delegate = self
        self.viewModel = viewModel
        
        if viewModel.images.first == nil {
            loadingIcon.startAnimating()
        } else {
            loadingIcon.stopAnimating()
            contentImageView.image = viewModel.images.first
            profileImageView.image = viewModel.profileImage
        }
        caption.text = viewModel.content
        caption.name = viewModel.nickname ?? ""
        caption.timestamp = viewModel.getTimestampString()

        guard viewModel.postId != "" else {
            return
        }
        
        FirebaseSubscriptionManager.shared.registerXPUpdates(for: viewModel.postId, ofType: .post) { [weak self] (xpModel) in
            
            guard let strongSelf = self else {
                return
            }
            let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(xpModel.level, .post)
            
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
        guard viewModel.postId == self.viewModel?.postId else {
            return
        }
        
        caption.name = viewModel.nickname
    }
    
    func didFetchProfileImage(viewModel: PostViewModel) {
        guard viewModel.postId == self.viewModel?.postId else {
            return
        }
        
        profileImageView.image = viewModel.profileImage
    }
    
    func didFetchPostImages(viewModel: PostViewModel) {
        guard viewModel.postId == self.viewModel?.postId else {
            return
        }
        
        contentImageView.image = viewModel.images.first
    }
    
    func setHeroIDs(forPost postID: String, forCaption captionID: String, forImage imageID: String) {
        isHeroEnabled = true
        postCard.heroID = postID
        caption.heroID = captionID
        profileImageView.heroID = imageID
    }
}
