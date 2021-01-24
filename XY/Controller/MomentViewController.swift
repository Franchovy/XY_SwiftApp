//
//  MomentViewController.swift
//  XY
//
//  Created by Maxime Franchot on 23/01/2021.
//

import UIKit
import AVFoundation

protocol MomentViewControllerDelegate: AnyObject {
    //func momentViewController(_ vc: MomentViewController, didTapCommentButtonFor post: MomentModel)
    
}


class MomentViewController: UIViewController {
        
    weak var delegate: MomentViewControllerDelegate?
    
    var model : MomentModel
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "test"), for: .normal)
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha  = 0.7
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.text = "Check out this video! #lol #xy"
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
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

    init(model: MomentModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(videoView)
        videoView.addSubview(spinner)

        setUpDoubleTapToLike()
        
        view.addSubview(captionLabel)
        view.addSubview(profileButton)
        
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        
        configureVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = videoView.center
        
        let size: CGFloat = 40
        
        captionLabel.sizeToFit()
        let labelHeight = captionLabel.sizeThatFits(CGSize(width: view.width - size - 12, height: view.height))
        captionLabel.frame = CGRect(
            x: 5,
            y: view.height - 10 - view.safeAreaInsets.bottom - labelHeight.height,
            width: view.width - size - 12,
            height: labelHeight.height
        )
        
        profileButton.frame = CGRect(
            x: 35,
            y: captionLabel.top - 5,
            width: size,
            height: size
        )
        profileButton.layer.cornerRadius = size / 2

    }

    
    public func play() {
        playState = .play
        
        self.player?.play()
    }
    
    public func configureVideo() {
        FirebaseDownload.getMoment(videoRef: model.videoRef) { [weak self] result in
            
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
    
    
    @objc func didTapShare() {
        guard let url = URL(string: "https://www.tiktok.com") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        
        present(vc, animated: true)
    }
    
    @objc func didTapProfileButton() {
        //delegate?.postViewController(self, didTapProfileButtonFor: model)
    }
    
    func setUpDoubleTapToLike() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        
        let touchPoint = gesture.location(in: view)
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.center = touchPoint
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 1
        } completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    UIView.animate(withDuration: 0.2) {
                        imageView.alpha = 0
                    } completion: { done in
                        if done {
                            imageView.removeFromSuperview()
                        }
                    }
                }
            }
        }
        
    }
    

}
