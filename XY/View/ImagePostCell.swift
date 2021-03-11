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


class ImagePostCell: UICollectionViewCell, FlowDataCell {
    
    // MARK: - Properties
    
    static let identifier = "imagePostCell"
    static var type: FlowDataType = .post
    var type: FlowDataType = .post
        
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
    
    private let caption: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = .white
        label.alpha = 1
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 14)
        label.textColor = .white
        label.alpha = 0.5
        return label
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
    var swipeAnimationDuration = 0.5
    
    var viewModel: NewPostViewModel?
    
    var delegate: ImagePostCellDelegate?
    
    var images: [UIImage]?
    
    var panGesture:UIPanGestureRecognizer!
    
    var tappedBackToCenterGesture = UITapGestureRecognizer()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(named: "Black")
        
        addSubview(reportButtonImage)
        addSubview(reportButtonTitle)
        
        addSubview(postCard)
        postCard.addSubview(loadingIcon)
        loadingIcon.startAnimating()
        
        postCard.addSubview(contentImageView)
        postCard.layer.insertSublayer(postShadowLayer, at: 0)
        
        postCard.addSubview(xpCircle)
        
        addSubview(caption)
        caption.addSubview(messageLabel)
        caption.addSubview(nameLabel)
        caption.addSubview(timestampLabel)
        
        profileImageContainer.addSubview(profileImageView)
        addSubview(profileImageContainer)
        
        postShadowLayer.path = UIBezierPath(roundedRect: postCard.bounds, cornerRadius: 15).cgPath
        postShadowLayer.shadowPath = postShadowLayer.path
        
        postShadowLayer.shadowRadius = 6
        postShadowLayer.shadowOffset = CGSize(width: 0, height: 8)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
//        panGesture.delegate = self
        panGesture.isEnabled = true
        addGestureRecognizer(panGesture)
        
        profileImageView.backgroundColor = .gray
        profileImageView.isUserInteractionEnabled = true
        
        contentView.isUserInteractionEnabled = false
        
        let tapProfileImage = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
//        tapProfileImage.delegate = self
        profileImageContainer.addGestureRecognizer(tapProfileImage)
        
        tappedBackToCenterGesture = UITapGestureRecognizer(target: self, action: #selector(animateBackToCenter))
        tappedBackToCenterGesture.isEnabled = false
        postCard.addGestureRecognizer(tappedBackToCenterGesture)
        
        reportButtonImage.addTarget(self, action: #selector(reportPressed), for: .touchUpInside)
        reportButtonTitle.addTarget(self, action: #selector(reportPressed), for: .touchUpInside)
        
        postCard.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        caption.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: width + 67 + 15).isActive = true
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
        
        loadingIcon.frame = CGRect(
            x: (postCard.width - 35)/2,
            y: (postCard.height - 35)/2,
            width: 35,
            height: 35
        )
        
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
        
//        caption.frame = CGRect(
//            x: profileImageContainer.right + 12,
//            y: isSwiping ? caption.top : postCard.bottom + 5,
//            width: caption.width,
//            height: caption.height
//        )
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 10,
            y: 4,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: caption.width - timestampLabel.width - 10,
            y: 4,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
        
        layoutChatBubble()
        
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
        super.prepareForReuse()
        
        // Load from data for this cell
        postShadowLayer.shadowOpacity = 0.0
        caption.alpha = 1.0
        postCard.alpha = 1.0
        profileImageView.alpha = 1.0
        profileImageContainer.alpha = 1.0
        caption.alpha = 1.0
        
        postCard.transform = CGAffineTransform.identity
        
        pauseTranslationX = 0
        didEndSwiping = false
        
        contentImageView.image = nil
        profileImageView.image = nil
        
        nameLabel.text = ""
        timestampLabel.text = ""
        setupMessage(text: "", colour: UIColor(0x287AFC))
        
        if let viewModel = viewModel {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: viewModel.id)
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
        profileImageContainer.heroID = "profileImage"
        
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
        if panGestureRecognizer.state == .cancelled {
            animateBackToCenter()
        }
        
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
        postCard.transform = CGAffineTransform(
                translationX: distance * (sqrt(swipeProgress)),
                y: 0
            ).rotated(
                by: directionMultiplier * sqrt(swipeProgress)/5
            ).scaledBy(
                x: (1-sqrt(swipeProgress)/10),
                y: (1-sqrt(swipeProgress)/10)
            )
        
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
        
        UIView.animate(withDuration: swipeAnimationDuration, delay: 0, options: .curveLinear) {
            self.postCard.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            self.postCard.alpha = 0.0
            self.caption.alpha = 0.0
            self.profileImageContainer.alpha = 0.0
            
        } completion: { (done) in
            if done {
                // Swipe Right
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
        
        UIView.animate(withDuration: swipeAnimationDuration, delay: 0, options: .curveLinear) {
            self.postCard.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            self.postCard.alpha = 0.0
            self.caption.alpha = 0.0
            self.profileImageContainer.alpha = 0.0
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
        guard let postId = viewModel?.id else {
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
    
    private func setupMessage(text: String, colour: UIColor) {
        
        messageLabel.numberOfLines = 0
        messageLabel.text = text

        let constraintRect = CGSize(width: 0.66 * width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: messageLabel.font],
                                            context: nil)
        messageLabel.frame.size = CGSize(width: ceil(boundingBox.width),
                                  height: ceil(boundingBox.height))


        caption.backgroundColor = UIColor(named: "XYblue")
        layoutChatBubble()
    }
    
    private func layoutChatBubble() {
        let bubbleSize = CGSize(
            width: max(messageLabel.frame.width + 32, nameLabel.width + timestampLabel.width + 20),
            height: max(messageLabel.frame.height + 37, 58)
        )

        let bubbleWidth = bubbleSize.width
        let bubbleHeight = bubbleSize.height

        caption.layer.cornerRadius = 15
    
        if !isSwiping && !didEndSwiping {
            caption.frame = CGRect(x: profileImageContainer.right + 10,
                                   y: postCard.bottom + 5,
                                   width: bubbleWidth,
                                   height: bubbleHeight)
        }
        messageLabel.frame.origin = CGPoint(x: 12, y: 31)
    }
    
    // MARK: - Public functions
    
    
    public func configure(with viewModel: NewPostViewModel) {
        
        self.viewModel = viewModel
        
        if viewModel.image == nil {
            loadingIcon.startAnimating()
        } else {
            loadingIcon.stopAnimating()
            contentImageView.image = viewModel.image
        }
        profileImageView.image = viewModel.profileImage
        nameLabel.text = viewModel.nickname
        timestampLabel.text = viewModel.timestamp.shortTimestamp()
        setupMessage(text: viewModel.content, colour: UIColor(0x287AFC))
        
        guard viewModel.id != "" else {
            return
        }
        
        FirebaseSubscriptionManager.shared.registerXPUpdates(for: viewModel.id, ofType: .post) { [weak self] (xpModel) in
            
            guard let strongSelf = self else {
                return
            }
            let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(xpModel.level, .post)
            
            strongSelf.xpCircle.onProgress(
                level: xpModel.level,
                progress: Float(xpModel.xp) / Float(nextLevelXP)
            )
        }
        
        let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .post)
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXP))
        xpCircle.setupFinished()
    }
    
    public func setHeroIDs(forPost postID: String, forCaption captionID: String, forImage imageID: String) {
        isHeroEnabled = true
        postCard.heroID = postID
        caption.heroID = captionID
        profileImageContainer.heroID = imageID
    }
}
