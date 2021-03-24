//
//  VideoViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit
import AVFoundation


class VideoViewController: UIViewController {
    
    private let profileShadowLayer = CAShapeLayer()
    private let profileBubble:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let xpCircleView = XPCircleView()
    
    private let levelLabel = VideoLevelLabel()
    
    private let followButton = FollowButton()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Bold", size: 25)
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowRadius = 3
        label.layer.shadowOpacity = 0.7
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 1.5
        label.layer.shadowOpacity = 0.8
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private var challengeLabel = GradientLabel(text: "", fontSize: 24, gradientColours: Global.xyGradient)
    
    private let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    public var shadowLayer = CAShapeLayer()
    
    enum PlayState {
        case play
        case pause
    }
    var playState:PlayState = .pause
    
    var playerLayer:AVPlayerLayer?
    var player: AVPlayer?
    
    private var playerDidFinishObserver: NSObjectProtocol?
    
    var challengeModel: ChallengeViewModel?
    var videoViewModel: ChallengeVideoViewModel?
    var xpModel: XPModel?
    
    var progress:CGFloat = 0.4
        
    private var timeControlObserverSet = false
    private var repeatObserverSet = false
    
    var tapAnywhereGesture: UITapGestureRecognizer!
    
    // MARK: - UI VARIABLES
    
    private var commentY:CGFloat = -10
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileBubble.addGestureRecognizer(tapProfileGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        tapGesture.delegate = self
        videoView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(videoPanned(gestureRecognizer:)))
        panGesture.delegate = self
        videoView.addGestureRecognizer(panGesture)
        
        tapAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere))
        tapAnywhereGesture.delegate = self
        videoView.addGestureRecognizer(tapAnywhereGesture)
        
        challengeLabel.isUserInteractionEnabled = true
        challengeLabel.addGestureRecognizer(tapAnywhereGesture)
        
        followButton.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.teardown()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 15
        
        view.addSubview(videoView)
        videoView.addSubview(spinner)
        
        view.addSubview(challengeLabel)
        view.addSubview(captionLabel)
        view.addSubview(userLabel)
        view.addSubview(xpCircleView)
        view.layer.addSublayer(profileShadowLayer)
        view.addSubview(profileBubble)
        view.addSubview(levelLabel)
        view.addSubview(followButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.path = UIBezierPath(roundedRect: videoView.bounds, cornerRadius: 15).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.insertSublayer(shadowLayer, at: 0)
        
        videoView.layer.cornerRadius = 15
        videoView.layer.masksToBounds = true
        videoView.frame = view.bounds
        
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = videoView.center
        
        // Bottom Text
        if let captionText = captionLabel.text {
            let constraintRect = CGSize(
                width: 300,
                height: 100
            )
            
            let boundingRect = captionText.boundingRect(with: constraintRect,
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [.font: captionLabel.font],
                                                        context: nil)
            
            captionLabel.frame = CGRect(
                x: 10,
                y: videoView.bottom - 10 - boundingRect.height,
                width: boundingRect.width,
                height: boundingRect.height
            )
        }
        
        challengeLabel.sizeToFit()
        challengeLabel.frame = CGRect(
            x: 10,
            y: captionLabel.top - 2.5 - challengeLabel.height,
            width: challengeLabel.width,
            height: challengeLabel.height
        )
        
        userLabel.sizeToFit()
        userLabel.frame = CGRect(
            x: 10,
            y: challengeLabel.top - userLabel.height - 7.5,
            width: userLabel.width,
            height: userLabel.height
        )
        
        followButton.frame = CGRect(
            x: userLabel.right + 8.3,
            y: userLabel.top + 5,
            width: 73,
            height: 23
        )
        
        let profileImageSize: CGFloat = 60
        let xpCircleSize: CGFloat = profileImageSize + 8
        xpCircleView.frame = CGRect(
            x: videoView.width - profileImageSize - 17,
            y: videoView.height/2 - profileImageSize/3,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        let levelLabelSize = CGSize(width: 68, height: 23)
        levelLabel.frame = CGRect(
            x: xpCircleView.left,
            y: xpCircleView.top - 10.29 - levelLabelSize.height,
            width: levelLabelSize.width,
            height: levelLabelSize.height
        )
        
        profileBubble.frame = CGRect(
            x: xpCircleView.left + 4,
            y: xpCircleView.top + 4,
            width: profileImageSize,
            height: profileImageSize
        )
        profileBubble.layer.cornerRadius = profileImageSize/2
        
        profileShadowLayer.frame = profileBubble.frame
        profileShadowLayer.fillColor = UIColor.black.cgColor
        profileShadowLayer.path = UIBezierPath(ovalIn: profileBubble.bounds).cgPath
        profileShadowLayer.shadowPath = UIBezierPath(ovalIn: profileBubble.bounds).cgPath
        profileShadowLayer.shadowColor = UIColor.black.cgColor
        profileShadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        profileShadowLayer.shadowRadius = 3
        profileShadowLayer.shadowOpacity = 0.7
    }
    
    // MARK: - Private Functions
    
    func teardown() {
        self.player?.pause()
        
        if timeControlObserverSet {
            
            player?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        if repeatObserverSet {
            NotificationCenter.default.removeObserver(self,
                                                      name: .AVPlayerItemDidPlayToEndTime,
                                                      object: self.player?.currentItem)
        }
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    // MARK: - Public Functions
    
    public func reconfigure() {
        setUpVideo()
    }
    
    public func unloadFromMemory() {
        player?.cancelPendingPrerolls()
//        teardown()
    }
    
    public func play() {
        playState = .play
        
        if let player = self.player, player.status == .readyToPlay {
            player.play()
        }
    }
    
    private func setProgressUI() {
        guard let xpModel = xpModel else {
            return
        }
        let progress = xpModel.getProgress()
        
        xpCircleView.animateSetProgress(CGFloat(progress))
        levelLabel.configure(for: xpModel.level)
        let color = levelLabel.getColor()
        xpCircleView.setColor(color)
    }
    
    public func swipedRight() {
        xpModel?.addXP(GameModel.swipeRightXP)
        
        guard let xpModel = xpModel else {
            return
        }
        
        levelLabel.configure(for: xpModel.level)
        let color = levelLabel.getColor()
        xpCircleView.setColor(color)
        xpCircleView.animateSetProgress(CGFloat(xpModel.getProgress()))
        
        guard let videoViewModel = videoViewModel, let challengeModel = challengeModel else {
            return
        }
        
        ActionManager.shared.swipeRight(
            contentID: "\(challengeModel.id)/\(FirebaseKeys.ChallengeKeys.CollectionPath.videos)/\(videoViewModel.id)",
            contentType: .challenge
        )
    }
    
    public func swipedLeft() {
        xpModel?.addXP(GameModel.swipeLeftXP)
        
        guard let xpModel = xpModel else {
            return
        }
        
        levelLabel.configure(for: xpModel.level)
        let color = levelLabel.getColor()
        xpCircleView.setColor(color)
        xpCircleView.animateSetProgress(CGFloat(xpModel.getProgress()))
        
        guard let videoViewModel = videoViewModel, let challengeModel = challengeModel else {
            return
        }
        
        ActionManager.shared.swipeLeft(
            contentID: "\(challengeModel.id)/\(FirebaseKeys.ChallengeKeys.CollectionPath.videos)/\(videoViewModel.id)",
            contentType: .challenge
        )
    }
    
    public func configure(challengeVideoViewModel: ChallengeVideoViewModel, challengeViewModel: ChallengeViewModel) {
        self.challengeModel = challengeViewModel
        self.videoViewModel = challengeVideoViewModel
        
        if let videoViewModel = videoViewModel {
            xpModel = XPModel(type: .challenge, xp: videoViewModel.xp, level: videoViewModel.level)
            self.setProgressUI()
        }
        
        // Request nickname for this user
        if let profileModel = challengeVideoViewModel.creator {
            
            ProfileViewModelBuilder.build(with: profileModel, fetchingCoverImage: false) { (profileViewModel) in
                if let profileViewModel = profileViewModel {
                    self.profileBubble.image = profileViewModel.profileImage
                    
                    self.followButton.configure(for: profileViewModel.relationshipType, otherUserID: profileViewModel.userId)
                    self.followButton.isHidden = false
                    
                    self.xpCircleView.setThickness(.thick)
                    self.xpCircleView.setBackgroundStyle(.glowColor)
                    
                    self.userLabel.text = profileModel.nickname
                    self.userLabel.sizeToFit()
                }
            }
        }
        
        captionLabel.text = challengeVideoViewModel.caption ?? challengeVideoViewModel.description
        
        challengeLabel.removeFromSuperview()
        challengeLabel = GradientLabel(text: challengeViewModel.title, fontSize: 26, gradientColours: challengeViewModel.category.getGradient())
        
        challengeLabel.layer.masksToBounds = false
        challengeLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        challengeLabel.layer.shadowRadius = 3
        challengeLabel.layer.shadowOpacity = 0.5
        challengeLabel.layer.shadowColor = UIColor.black.cgColor
        
        view.addSubview(challengeLabel)
        
        let tappedTitle = UITapGestureRecognizer(target: self, action: #selector(titleTapped(_:)))
        challengeLabel.isUserInteractionEnabled = true
        challengeLabel.addGestureRecognizer(tappedTitle)
        
        setUpVideo()
    }
    
    private func subscribeToXP() {
        guard let challengeModel = challengeModel, let videoViewModel = videoViewModel else {
            return
        }
        ChallengesFirestoreManager.shared.subscribeToVideoXP(challengeID: challengeModel.id, videoID: videoViewModel.id) { level, xp in
            
        }
    }
    
    private func setUpVideo() {
        guard let url = videoViewModel?.videoUrl else {
            return
        }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        videoView.frame = playerLayer.bounds
        videoView.layer.addSublayer(playerLayer)
        
        guard let player = player else {
            return
        }
        
        player.volume = 1.0
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        timeControlObserverSet = true
        
        if playState == .play {
            player.play()
        }
        player.play()
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak self] _ in
            if self == nil {
                return
            }
            player.seek(to: .zero)
            player.play()
        }
        repeatObserverSet = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        guard let player = player else {
            return
        }
        
        if object as AnyObject? === player {
            if keyPath == "timeControlStatus" {
                if player.timeControlStatus == .playing {
//                    player.play()
                }
            }
        }
    }
    
    // MARK: - Obj-C functions
    
    @objc private func captionPanned(gestureRecognizer: UIPanGestureRecognizer) {
        
        commentY += gestureRecognizer.location(in: view).y
        
        let modelText: String!
        switch Int.random(in: 0...5) {
        case 0:
            modelText = "Wooahh dude!!!"
        case 1:
            modelText = "Bro. That's mad"
        case 2:
            modelText = "COVID ISNT REAL"
        case 3:
            modelText = "Man you are insane"
        case 4:
            modelText = "I love you omg"
        default:
            modelText = "I love it omg"
        }
        
        var commentView = CommentView(text: modelText, color: UIColor(named: "XYblue")!)
        
        commentView.frame = CGRect(
            x: view.width / 9,
            y: commentY,
            width: view.width * 7/9,
            height: 75
        )
    }
    
    @objc private func videoPanned(gestureRecognizer: UIPanGestureRecognizer) {
        let translationX = gestureRecognizer.translation(in: view).x
        
        videoView.transform = CGAffineTransform(
            translationX: translationX,
            y: 0
        )
    }
    
    var stoppedAnimationFrame: CGRect?
    @objc private func videoTapped() {
        if let card = card {
            didTapAnywhere()
            return
        }
        
        guard let player = player else {
            return
        }
        
        if playState == .pause && player.status == .readyToPlay {
            player.play()
            playState = .play
            
        } else {
            player.pause()
            playState = .pause
            
        }
    }
    
    @objc private func profileImageTapped() {
        guard let profileModel = videoViewModel?.creator else {
            return
        }
        player?.pause()
        ProfileManager.shared.openProfileForId(profileModel.profileId)
    }
    
    var card: ChallengePreviewCard?
    
    @objc private func titleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let card = card {
            didTapAnywhere()
            return
        }
        
        guard let challengeModel = challengeModel else {
            return
        }
        
        let card = ChallengePreviewCard()
        self.card = card
        card.configure(with: challengeModel)
        card.heroID = "card"
        isHeroEnabled = true
        
        view.addSubview(card)
        card.frame = CGRect(
            x: max(gestureRecognizer.location(in: videoView).x - 75, 15),
            y: gestureRecognizer.location(in: videoView).y - 15 - 200,
            width: 150,
            height: 200
        )
        
        card.alpha = 0.0
        card.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.25) {
            card.alpha = 1.0
            card.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { (done) in
            if done {
                
            }
        }
    }
    
    @objc private func didTapAnywhere() {
        guard let card = card else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            card.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            card.alpha = 0.0
        } completion: { (done) in
            if done {
                card.removeFromSuperview()
                self.card = nil
            }
        }
    }
}

extension VideoViewController : UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else {
//            if gestureRecognizer.view == videoView {
//                return !challengeLabel.frame.contains(gestureRecognizer.location(in: view))
//            }
            return true
        }
        
    }
}

extension VideoViewController : ProfileBubbleDelegate {
    func plusButtonPressed() {
        
    }
}
