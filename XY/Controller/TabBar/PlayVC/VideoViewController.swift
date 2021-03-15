//
//  VideoViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit
import AVFoundation

protocol VideoViewControllerDelegate: class {
    func didTapTitle(for viewModel: ChallengeViewModel)
}

class VideoViewController: UIViewController {
    
//    private let profileButtonShadowLayer = CAShapeLayer()
//    private let profileButton: UIButton = {
//        let button = UIButton()
//        button.setBackgroundImage(UIImage(named: "test"), for: .normal)
//        button.layer.masksToBounds = true
//        button.contentMode = .scaleAspectFill
//        button.tintColor = .white
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.white.cgColor
//        return button
//    }()
    
    private let profileBubble = ProfileBubble()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Heavy", size: 25)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 18)
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
    
    weak var delegate: VideoViewControllerDelegate?
    
    private var timeControlObserverSet = false
    private var repeatObserverSet = false
    
    // MARK: - UI VARIABLES
    
    private var commentY:CGFloat = -10
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileBubble.addGestureRecognizer(tapProfileGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        videoView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(videoPanned(gestureRecognizer:)))
        panGesture.delegate = self
        videoView.addGestureRecognizer(panGesture)
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
        view.addSubview(profileBubble)
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
                y: videoView.bottom - 31 - boundingRect.height,
                width: boundingRect.width,
                height: boundingRect.height
            )
        }
        
        challengeLabel.sizeToFit()
        challengeLabel.frame = CGRect(
            x: 10,
            y: captionLabel.top - 8.85 - challengeLabel.height,
            width: challengeLabel.width,
            height: challengeLabel.height
        )
        
        userLabel.sizeToFit()
        userLabel.frame = CGRect(
            x: 10,
            y: challengeLabel.top - userLabel.height - 6.2,
            width: userLabel.width,
            height: userLabel.height
        )
        
        // Side buttons
        
        let size: CGFloat = 60
        profileBubble.frame = CGRect(
            x: videoView.width - size - 11,
            y: videoView.height/2 - size/3,
            width: size,
            height: size
        )
    }
    
    // MARK: - Private Functions
    
    private func teardown() {
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
    
    public func configure(challengeVideoViewModel: ChallengeVideoViewModel, challengeViewModel: ChallengeViewModel) {
        self.challengeModel = challengeViewModel
        self.videoViewModel = challengeVideoViewModel
        
        // Request nickname for this user
        if let profileModel = challengeVideoViewModel.creator {
            
            ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                if let profileViewModel = profileViewModel {
                    self.profileBubble.configure(with: profileViewModel, followButtonPos: .forVideo)
                    
                    self.userLabel.text = profileModel.nickname
                    self.userLabel.sizeToFit()
                }
            }
        }
        
        captionLabel.text = challengeVideoViewModel.caption ?? challengeVideoViewModel.description
        
        challengeLabel.removeFromSuperview()
        challengeLabel = GradientLabel(text: challengeViewModel.title, fontSize: 26, gradientColours: challengeViewModel.category.getGradient())
        view.addSubview(challengeLabel)
        
        let tappedTitle = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        challengeLabel.isUserInteractionEnabled = true
        challengeLabel.addGestureRecognizer(tappedTitle)
        
        setUpVideo()
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
    
    @objc private func titleTapped() {
        guard let challengeModel = challengeModel else {
            return
        }
        delegate?.didTapTitle(for: challengeModel)
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
