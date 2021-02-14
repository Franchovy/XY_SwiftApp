//
//  ViralViewController.swift
//  XY
//
//  Created by Maxime Franchot on 26/01/2021.
//

import UIKit
import AVFoundation


class ViralViewController: UIViewController {
    
    var model : ViralModel
    
    private let healthBar: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(0xFF4A4A).cgColor,
            UIColor(0xFD963A).cgColor,
            UIColor(0xFD9A39).cgColor,
            UIColor(0xFF4A4A).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 0)
        layer.locations = [
            0.0,
            0.45,
            0.75,
            1.0
        ]
        return layer
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "test"), for: .normal)
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.alpha  = 0.7
        label.font = UIFont(name: "HelveticaNeue", size: 18)
        return label
    }()
    
    public var shadowLayer = CAShapeLayer()
    
    enum PlayState {
        case play
        case pause
    }
    var playState:PlayState = .pause
    
    var player: AVPlayer!
    
    private var playerDidFinishObserver: NSObjectProtocol?
    
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
    
    private var timeControlObserverSet = false
    private var repeatObserverSet = false
    
    // MARK: - Initializers

    init(model: ViralModel) {
        self.model = model
        captionLabel.text = model.caption
//        player = AVPlayer(url: model.vid)
        
        super.init(nibName: nil, bundle: nil)
        
        profileButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        view.addGestureRecognizer(tapGesture)
        
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
        
        view.addSubview(captionLabel)
        view.addSubview(userLabel)
        view.addSubview(profileButton)
              
        configureVideo()

        videoView.layer.insertSublayer(healthBar, above: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        healthBar.frame = CGRect(
            x: 0,
            y: 0,
            width: self.videoView.width * getHealthBarPercentage(
                forLives: model.lives,
                forLevel: model.level
            ),
            height: 11
        )
        
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
                x: 5,
                y: videoView.bottom - 31 - boundingRect.height,
                width: boundingRect.width,
                height: boundingRect.height
            )
        }
        
        let size: CGFloat = 40
        profileButton.frame = CGRect(
            x: 5,
            y: captionLabel.top - 5 - size,
            width: size,
            height: size
        )
        profileButton.layer.cornerRadius = size / 2

        userLabel.sizeToFit()
        userLabel.frame = CGRect(
            x: profileButton.right + 5,
            y: captionLabel.top - 5 - userLabel.height,
            width: userLabel.width,
            height: userLabel.height
        )
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


    
    private func getHealthBarPercentage(forLives currentLives: Int, forLevel currentLevel: Int) -> CGFloat {
        
        let maxLife = XPModelManager.shared.getLivesLeftForLevel(currentLevel)
        
        return CGFloat(currentLives) / CGFloat(maxLife)
    }
    
    var animationPlayed = false
    private func beginHealthBarAnimation() {
        guard !animationPlayed, let videoLength = player?.currentItem?.asset.duration else {
            return
        }
        
        let newFrame = CGRect(
            x: healthBar.frame.origin.x,
            y: healthBar.frame.origin.y,
            width: self.videoView.width * self.getHealthBarPercentage(
                forLives: self.model.lives - 1,
                forLevel: self.model.level
            ) * 0.8, // Amplify the effect a little bit
            height: healthBar.frame.size.height
        )
        
        healthBar.resizeAndMove(frame: newFrame, animated: true, duration: videoLength.seconds)
        
        animationPlayed = true
    }
    
    
    func pauseAnimation(){
        
        let pausedTime = healthBar.convertTime(CACurrentMediaTime(), from: nil)
        healthBar.speed = 0.0
        healthBar.timeOffset = pausedTime
    }
    
    func resumeAnimation(){
        let pausedTime = healthBar.timeOffset
        healthBar.speed = 1.0
        healthBar.timeOffset = 0.0
        healthBar.beginTime = 0.0
        let timeSincePause = healthBar.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        healthBar.beginTime = timeSincePause
    }

    
    private func onPlay() {
        beginHealthBarAnimation()
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
                
                strongSelf.videoView.layer.insertSublayer(
                    playerLayer,
                    below: strongSelf.healthBar
                )
                strongSelf.videoView.frame = playerLayer.bounds
                strongSelf.player?.volume = 1.0

                guard let player = strongSelf.player else {
                    return
                }
                
                player.addObserver(strongSelf, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
                strongSelf.timeControlObserverSet = true
                
                if strongSelf.playState == .play {
                    strongSelf.player?.play()
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
                    onPlay()
                }
            }
        }
    }
    
    // MARK: - Obj-C functions
    
    var stoppedAnimationFrame: CGRect?
    @objc private func videoTapped() {
        if playState == .pause && player.status == .readyToPlay {
            player?.play()
            playState = .play
            
            resumeAnimation()
        } else {
            player?.pause()
            playState = .pause
            
            pauseAnimation()
        }
    }
    
    @objc private func profileImageTapped() {
        player?.pause()
        ProfileManager.shared.openProfileForId(model.profileId)
    }
}
