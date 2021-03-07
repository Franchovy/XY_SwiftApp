//
//  VideoViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    
    private let profileButtonShadowLayer = CAShapeLayer()
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "test"), for: .normal)
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
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
    
    private let challengeLabel: GradientLabel
    
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
    var player: AVPlayer!
    
    private var playerDidFinishObserver: NSObjectProtocol?
    
    var model : VideoModel
    
    private var timeControlObserverSet = false
    private var repeatObserverSet = false
    
    // MARK: - UI VARIABLES
    
    private var commentY:CGFloat = -10
    
    // MARK: - Initializers
    
    init(model: VideoModel) {
        self.model = model
        captionLabel.text = model.caption
        
        challengeLabel = GradientLabel(
            text: [
                "#XYCHALLENGE",
                "#EATCHALLENGE",
                "#SPORTCHALLENGE",
                "#LIFECHALLENGE",
                "#WATCHCHALLENGE",
                "#PLAYCHALLENGE"
            ][Int.random(in: 0...5)],
            fontSize: 20,
            gradientColours: [
                Global.xyGradient,
                Global.rastaGradient,
                Global.metallicGradient][Int.random(in: 0...2)]
        )
        
        super.init(nibName: nil, bundle: nil)
        
        profileButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(videoPanned(gestureRecognizer:)))
        panGesture.delegate = self
        videoView.addGestureRecognizer(panGesture)
        
        // Request nickname for this user
        fetchProfileData()
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
        view.addSubview(profileButton)
        
        configureVideo()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.path = UIBezierPath(roundedRect: videoView.bounds, cornerRadius: 15).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        
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
        profileButton.frame = CGRect(
            x: view.width - size - 11,
            y: view.height/2 - size/3,
            width: size,
            height: size
        )
        profileButton.layer.cornerRadius = size / 2
        
        let path = UIBezierPath(roundedRect: profileButton.frame, cornerRadius: size/2).cgPath
        profileButtonShadowLayer.path = path
        profileButtonShadowLayer.shadowPath = path
        profileButtonShadowLayer.fillColor = UIColor.black.cgColor
        profileButtonShadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        profileButtonShadowLayer.shadowRadius = 6
        profileButtonShadowLayer.shadowOpacity = 0.8
        profileButtonShadowLayer.shadowColor = UIColor.black.cgColor
        profileButtonShadowLayer.masksToBounds = false
        
        view.layer.insertSublayer(profileButtonShadowLayer, below: profileButton.layer)
    }
    
    // MARK: - Private Functions
    
    private func teardown() {
        self.player?.pause()
        
        if timeControlObserverSet {
            
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        if repeatObserverSet {
            NotificationCenter.default.removeObserver(self,
                                                      name: .AVPlayerItemDidPlayToEndTime,
                                                      object: self.player?.currentItem)
        }
        self.player = nil
    }
    
    private func fetchProfileData() {
        FirebaseDownload.getProfile(profileId: model.profileId) { [weak self] (profileModel, error) in
            guard let strongSelf = self, let profileModel = profileModel, error == nil else {
                return
            }
            
            strongSelf.userLabel.text = profileModel.nickname
            strongSelf.userLabel.sizeToFit()
            
            FirebaseDownload.getImage(imageId: profileModel.profileImageId) { [weak self] (image, error) in
                guard let strongSelf = self, let image = image, error == nil else {
                    return
                }
                
                strongSelf.profileButton.setBackgroundImage(image, for: .normal)
            }
        }
    }
    
    // MARK: - Public Functions
    
    public func play() {
        playState = .play
        
        if let player = self.player, player.status == .readyToPlay {
            player.play()
        }
    }
    
    public func configureVideo() {
        
        StorageManager.shared.downloadVideo(videoId: model.videoRef, containerId: model.id) { [weak self] result in
            
            guard let strongSelf = self else { return }
            strongSelf.spinner.stopAnimating()
            strongSelf.spinner.removeFromSuperview()
            switch result {
            case .failure(let error):
                print("Error fetching video: \(error)")
            case .success(let url):
                strongSelf.player = AVPlayer(url: url)
                
                let playerLayer = AVPlayerLayer(player: strongSelf.player)
                playerLayer.frame = strongSelf.videoView.bounds
                playerLayer.videoGravity = .resizeAspectFill
                
                strongSelf.videoView.frame = playerLayer.bounds
                strongSelf.videoView.layer.addSublayer(playerLayer)
                
                guard let player = strongSelf.player else {
                    return
                }
                
                player.volume = 1.0
                player.addObserver(strongSelf, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                strongSelf.timeControlObserverSet = true
                
                if strongSelf.playState == .play {
                    player.play()
                }
                
                strongSelf.playerDidFinishObserver = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
                strongSelf.repeatObserverSet = true
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        guard let player = player else {
            return
        }
        
        if object as AnyObject? === player {
            if keyPath == "timeControlStatus" {
                if player.timeControlStatus == .playing {
                    //
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
        if playState == .pause && player.status == .readyToPlay {
            player?.play()
            playState = .play
            
        } else {
            player?.pause()
            playState = .pause
            
        }
    }
    
    @objc private func profileImageTapped() {
        player?.pause()
        ProfileManager.shared.openProfileForId(model.profileId)
    }
}

extension VideoViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gesture.velocity(in: nil)
            return abs(velocity.x) > abs(velocity.y)
        }
        else { return true }
        
    }
}
