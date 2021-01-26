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
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha  = 0.7
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 26)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha  = 0.7
        label.font = UIFont(name: "HelveticaNeue", size: 24)
        return label
    }()
    
    public var shadowLayer = CAShapeLayer()
    
    enum PlayState {
        case play
        case pause
    }
    var playState:PlayState = .pause
    
    var player: AVPlayer?
    
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
    
    // MARK: - Initializers

    init(model: ViralModel) {
        self.model = model
        captionLabel.text = model.caption
        super.init(nibName: nil, bundle: nil)
        
        // Request nickname for this user
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(videoView)
        videoView.addSubview(spinner)
        
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
        
        let size: CGFloat = 40
        
//        captionLabel.sizeToFit()
        let labelHeight = captionLabel.sizeThatFits(CGSize(width: view.width - size - 12, height: view.height))
        captionLabel.frame = CGRect(
            x: 5,
            y: videoView.bottom - 10 - labelHeight.height,
            width: videoView.width - size - 12,
            height: labelHeight.height
        )

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

    // MARK: - Public Functions
    
    public func play() {
        playState = .play
        
        self.player?.play()
    }
    
    public func configureVideo() {
        FirebaseDownload.getVideo(videoRef: model.videoRef) { [weak self] result in
            
            guard let strongSelf = self else { return }
            strongSelf.spinner.stopAnimating()
            strongSelf.spinner.removeFromSuperview()
            switch result {
            case .failure(let error):
                print("Error fetching video: \(error)")
            case .success(let url):
                DispatchQueue.main.async {
                    strongSelf.player = AVPlayer(url: url)
                    let playerLayer = AVPlayerLayer(player: strongSelf.player)
                    playerLayer.frame = strongSelf.view.bounds
                    playerLayer.videoGravity = .resizeAspectFill
                    strongSelf.videoView.layer.addSublayer(playerLayer)
                    strongSelf.player?.volume = 1.0
                    
                    if strongSelf.playState == .play {
                        strongSelf.player?.play()
                    }
                    
                    guard let player = strongSelf.player else {
                        return
                    }
                    
                    strongSelf.playerDidFinishObserver = NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
            }
        }
    }
}
