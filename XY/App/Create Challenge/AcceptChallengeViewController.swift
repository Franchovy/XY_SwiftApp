//
//  AcceptChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 12/04/2021.
//

import UIKit

class AcceptChallengeViewController: UIViewController {

    var videoURL: URL?
    
    private let cameraViewController = CameraViewController()
    private let recordButton = RecordButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentingViewController?.navigationItem.backButtonTitle = " "
        
        view.addSubview(cameraViewController.view)
        addChild(cameraViewController)
        
        view.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.xmark)
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let acceptedChallenge = CreateChallengeManager.shared.acceptedChallenge else {
            return
        }
        challengeAcceptedPrompt(viewModel: acceptedChallenge)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraViewController.view.frame = view.bounds
        
        let recordButtonSize: CGFloat = 64
        recordButton.frame = CGRect(
            x: (view.width - recordButtonSize)/2,
            y: view.bottom - recordButtonSize - 15,
            width: recordButtonSize,
            height: recordButtonSize
        )
    }
    
    // MARK: -
    
    private func challengeAcceptedPrompt(viewModel: ChallengeCardViewModel) {
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.frame = view.bounds
        
        // picture
        let bubble = FriendBubble()
        bubble.setImage(viewModel.senderProfile!.image)
        view.addSubview(bubble)
        bubble.frame = CGRect(x: (view.width - 70)/2, y: 92, width: 70, height: 70)
        
        // label
        let label = Label("\(viewModel.senderProfile!.nickname) challenged you to:", style: .title, fontSize: 18, adaptToLightMode: false)
        view.addSubview(label)
        label.sizeToFit()
        label.frame = CGRect(x: (view.width - label.width)/2, y: bubble.bottom + 3, width: label.width, height: label.height)
        
        // card
        let card = ChallengeCard()
        view.addSubview(card)
        card.configure(with: viewModel)
        card.frame = CGRect(x: (view.width - 248.14)/2, y: label.bottom + 27.39, width: 248.14, height: 389.4)
        
        // start
        let button = Button(image: UIImage(systemName: "video.fill"), title: "Record", style: .roundButton(backgroundColor: .red), font: UIFont(name: "Raleway-Heavy", size: 26), paddingVertical: 5)
        view.addSubview(button)
        button.sizeToFit()
        button.frame = CGRect(x: (view.width - button.width)/2, y: card.bottom + 35, width: button.width, height: button.height)
        
    }
    
    private func displayPreview() {
        guard let videoURL = videoURL else {
            return
        }
        let previewVC = PreviewViewController(previewVideoURL: videoURL)
        
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    // MARK: - OBJ-C FUNCTIONS
    
    @objc private func recordButtonPressed() {
        if cameraViewController.state == .prepareToRecord {
            cameraViewController.startRecording()
            recordButton.setState(.recording)
        } else {
            recordButton.setState(.notRecording)
            cameraViewController.stopRecording() { outputUrl in
                self.videoURL = outputUrl
                
                DispatchQueue.main.async {
                    self.displayPreview()
                }
            }
        }
    }
}
