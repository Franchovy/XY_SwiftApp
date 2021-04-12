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
    
    private let sendButton = Button(
        image: UIImage(systemName: "paperplane.fill")!,
        style: .circular(backgroundColor: UIColor(0x007BF5))
    )

    init(previewVideoURL: URL) {
        self.previewVideoURL = previewVideoURL
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBlack")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(videoView)
        
        videoView.setUpVideo(videoURL: previewVideoURL, withRate: 1.0, audioEnable: true)
        
        videoView.isUserInteractionEnabled = true
        videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapVideo)))
        
        videoView.layer.cornerRadius = 10
        videoView.layer.masksToBounds = true
        
        sendButton.alpha = 0.0
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
        navigationController?.configureBackgroundStyle(.invisible)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(didTapClose))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appearSendButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        videoView.player?.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.bounds.inset(by: UIEdgeInsets(top: 46, left: 0, bottom: 80, right: 0))
        
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
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseIn) {
            self.sendButton.transform = .identity
            self.sendButton.alpha = 1.0
        }
    }
    
    @objc private func didTapClose() {
        let prompt = Prompt()
        prompt.setTitle(text: "Discard Challenge")
        prompt.addText(text: "By discarding this challenge you will lose the video you've just recorded.")
        prompt.addCompletionButton(buttonText: "Quit", textColor: UIColor(0xEF3A30), style: .embedded, onTap: {
            NavigationControlManager.backToCamera()
        })
        prompt.addCompletionButton(buttonText: "Cancel", style: .embedded, closeOnTap: true)
        
        view.addSubview(prompt)
        prompt.appear()
    }
    
    @objc private func didTapVideo() {
        guard let player = videoView.player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @objc private func didTapNext() {
        CreateChallengeManager.shared.setVideoUrl(url: previewVideoURL)
        
        if CreateChallengeManager.shared.title != nil && CreateChallengeManager.shared.description != nil {
            guard let cardViewModel = CreateChallengeManager.shared.getChallengeCardViewModel() else {
                return
            }
            
            let vc = SendChallengeViewController(with: cardViewModel)
            
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = DescriptionViewController()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
