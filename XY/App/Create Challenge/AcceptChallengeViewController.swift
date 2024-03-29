//
//  AcceptChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 12/04/2021.
//

import UIKit

class AcceptChallengeViewController: UIViewController, CameraContainerDelegate {

    var videoURL: URL?
    
    private let closeButton = Button(image: UIImage(systemName: "xmark"), style: .image)
    
    private let cameraViewController = CameraContainerViewController()

    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    private var challengeTitleLabel: Label?
    
    private let bubble = FriendBubble()
    private let challengedYouLabel = Label(style: .title, fontSize: 18, adaptToLightMode: false)
    private let challengeCard = ChallengeCard()
    private let startButton = Button(image: UIImage(systemName: "video.fill"), title: "Record", style: .roundButton(backgroundColor: .red), font: UIFont(name: "Raleway-Heavy", size: 26), paddingVertical: 5)
    
    private var displayingCard = true
    
    init(viewModel: ChallengeCardViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        bubble.configure(with: viewModel.senderProfile!)
        challengedYouLabel.text = "\(viewModel.senderProfile!.nickname) challenged you to:"
        
        challengeCard.configure(with: viewModel)
        
        cameraViewController.delegate = self
        
        view.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cameraViewController.view)
        addChild(cameraViewController)
        
        cameraViewController.view.layer.cornerRadius = 10
        
        view.addSubview(blurView)
        view.addSubview(bubble)
        view.addSubview(challengedYouLabel)
        view.addSubview(challengeCard)
        view.addSubview(startButton)
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if displayingCard {
            blurView.frame = view.bounds
            
            bubble.frame = CGRect(x: (view.width - 70)/2, y: 92, width: 70, height: 70)
            
            challengedYouLabel.sizeToFit()
            challengedYouLabel.frame = CGRect(x: (view.width - challengedYouLabel.width)/2, y: bubble.bottom + 3, width: challengedYouLabel.width, height: challengedYouLabel.height)
            
            challengeCard.frame = CGRect(x: (view.width - 248.14)/2, y: challengedYouLabel.bottom + 27.39, width: 248.14, height: 389.4)
            
            startButton.sizeToFit()
            startButton.frame = CGRect(x: (view.width - startButton.width)/2, y: challengeCard.bottom + 35, width: startButton.width, height: startButton.height)
        } else {
            self.challengeTitleLabel!.frame.origin = CGPoint(x: (self.view.width - self.challengeTitleLabel!.width)/2, y: 50)
        }
        
        cameraViewController.view.frame = view.bounds.inset(by: UIEdgeInsets(top: 46, left: 0, bottom: 80, right: 0))
    }
    
    // MARK: -
    
    private func displayPreview() {
        guard let videoURL = videoURL else {
            return
        }
        let previewVC = PreviewViewController(previewVideoURL: videoURL)
        
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    // MARK: - OBJ-C FUNCTIONS
    
    func didFinishRecording(videoURL: URL) {
        self.videoURL = videoURL
        
        DispatchQueue.main.async {
            self.displayPreview()
        }
    }
    
    func closeButtonPressed() {
        CreateChallengeManager.shared.clearData()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func startButtonPressed() {
        displayingCard = false
        
        challengeTitleLabel = self.challengeCard.extractTitle()
        view.addSubview(challengeTitleLabel!)
        
        challengeTitleLabel?.center = challengeCard.center
        
        self.startButton.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0.0
            self.challengeCard.alpha = 0.0
            self.challengedYouLabel.alpha = 0.0
            self.startButton.alpha = 0.0
            self.bubble.alpha = 0.0
            
            self.challengeTitleLabel!.font = UIFont(name: "Raleway-Heavy", size: 31)
            self.challengeTitleLabel!.sizeToFit()
            self.challengeTitleLabel!.frame.origin = CGPoint(x: (self.view.width - self.challengeTitleLabel!.width)/2, y: 50)
        } completion: { (done) in
            if done {
                
            }
        }
    }
}
