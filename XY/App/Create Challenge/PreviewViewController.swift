//
//  PreviewViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController {
    
    let videoView = VideoPlayerView()
    let previewVideoURL: URL
    
    private let sendButton = Button(image: UIImage(systemName: "paperplane")!, backgroundColor: UIColor(0x007BF5), style: .circular)

    init(previewVideoURL: URL) {
        self.previewVideoURL = previewVideoURL
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(videoView)
        
        videoView.setUpVideo(videoURL: previewVideoURL, withRate: 1.0, audioEnable: true)
        
        sendButton.alpha = 0.0
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.xmark)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appearSendButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.bounds
        
        let sendButtonSize: CGFloat = 50
        sendButton.frame = CGRect(
            x: view.width - sendButtonSize - 15,
            y: view.height - sendButtonSize - 15,
            width: sendButtonSize,
            height: sendButtonSize
        )
    }
    
    private func appearSendButton() {
        sendButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.4, delay: 1.0, options: .curveEaseIn) {
            self.sendButton.transform = .identity
            self.sendButton.alpha = 1.0
        }
    }
    
    @objc private func didTapNext() {
        if CreateChallengeManager.shared.title != nil && CreateChallengeManager.shared.description != nil {
            let vc = SendChallengeViewController()
            
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CreateChallengeDescriptionViewController()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
