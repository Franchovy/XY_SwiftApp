//
//  PlayerViewController.swift
//  XY
//
//  Created by Maxime Franchot on 09/04/2021.
//

import UIKit
import AVKit


class PlayerViewController: UIViewController {
    
    let challengeFooter = VideoFooterView()
    let challengeHeader = VideoHeaderView()
    
    private var player: AVPlayer?
    private var videoLayer: AVPlayerLayer?
    
    var repeatObserverSet: Bool = false
    private var playerDidFinishObserver: NSObjectProtocol?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player?.pause()

        if repeatObserverSet {
            NotificationCenter.default.removeObserver(self,
                                                      name: .AVPlayerItemDidPlayToEndTime,
                                                      object: player?.currentItem)
        }
        
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = [
            Bundle.main.url(forResource: "video1", withExtension: "mov"),
            Bundle.main.url(forResource: "video2", withExtension: "mov"),
            Bundle.main.url(forResource: "video3", withExtension: "mov"),
            Bundle.main.url(forResource: "video4", withExtension: "mov"),
            Bundle.main.url(forResource: "video5", withExtension: "mov")
        ][Int.random(in: 0...4)]
        configureVideo(from: url!)
        
        configureChallengeCard(
            with: ChallengeCardViewModel.fakeData.randomElement()!,
            profileViewModel: FriendBubbleViewModel.generateFakeData().randomElement()!
        )
        
        view.addSubview(challengeHeader)
        view.addSubview(challengeFooter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeHeader.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: 90
        )
        
        if let videoLayer = videoLayer {
            videoLayer.frame = view.bounds
        }
        
        challengeFooter.sizeToFit()
        challengeFooter.frame = CGRect(
            x: 0,
            y: view.height - challengeFooter.height,
            width: view.width,
            height: challengeFooter.height
        )
    }
    
    func configureChallengeCard(with challengeCardViewModel: ChallengeCardViewModel, profileViewModel: FriendBubbleViewModel) {
        challengeHeader.configure(challengeName: challengeCardViewModel.title)
        challengeFooter.configure(profileViewModel: profileViewModel, challengeViewModel: challengeCardViewModel)
    }
    
    func configureVideo(from url: URL) {
        player = AVPlayer(url: url)
        
        videoLayer = AVPlayerLayer(player: player)
        videoLayer!.frame = view.bounds
        videoLayer!.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(videoLayer!)
        
        guard let player = player else {
            return
        }
        
        player.play()
        
        player.volume = 1.0
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak self] _ in
            player.seek(to: .zero)
            player.play()
        }
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak self] _ in
            player.seek(to: .zero)
            player.play()
        }
        
        repeatObserverSet = true
    }
    
    public func viewAppeared() {
        challengeHeader.appear()
    }
    
    public func play() {
        player?.play()
    }
    
    public func pause() {
        player?.pause()
    }
    
    @objc private func didTap() {
        guard let player = player else {
            return
        }
        if player.timeControlStatus == .paused {
            play()
            showPlayIcon()
        } else {
            pause()
            showPauseIcon()
        }
    }
    
    private func showPlayIcon() {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView.center = view.center
        view.addSubview(imageView)
        
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 0.6
            imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2) {
                    imageView.alpha = 0.0
                    imageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                } completion: { (done) in
                    if done {
                        imageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func showPauseIcon() {
        let imageView = UIImageView(image: UIImage(systemName: "pause.fill"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView.center = view.center
        view.addSubview(imageView)
        
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 0.6
            imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2) {
                    imageView.alpha = 0.0
                    imageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                } completion: { (done) in
                    if done {
                        imageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
}
