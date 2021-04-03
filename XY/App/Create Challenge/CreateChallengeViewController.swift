//
//  CreateChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class CreateChallengeViewController: UIViewController {
    
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
        
        displayNewChallengePrompt()
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
    
    private func displayNewChallengePrompt() {
        let prompt = Prompt()
        
        prompt.setTitle(text: "Create Challenge", isGradient: true)
        prompt.addTextField(placeholderText: "What is your challenge called?", maxChars: 15, font: UIFont(name: "Raleway-Heavy", size: 15)!)
        prompt.addTextField(placeholderText: "Write a description for your challenge", maxChars: 50)
        prompt.addButton(
            buttonText: "Record",
            backgroundColor: UIColor(0xF23333),
            textColor: UIColor(named: "XYWhite")!,
            icon: UIImage(systemName: "video.fill"),
            style: .action,
            closeOnTap: true,
            onTap: nil,
            target: nil
        )
        prompt.addExternalButton()
        prompt.onCompletion = { inputTexts in
            if let challengeTitle = inputTexts.first, let challengeDescription = inputTexts.last {
                print("Challenge title: \(challengeTitle)")
                print("Description title: \(challengeDescription)")
                
                CreateChallengeManager.shared.title = challengeTitle
                CreateChallengeManager.shared.description = challengeDescription
            }
        }
        
        view.addSubview(prompt)
        
        prompt.appear()
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
