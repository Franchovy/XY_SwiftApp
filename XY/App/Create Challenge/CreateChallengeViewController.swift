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
        
        cameraViewController.view.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.xmark)
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoURL = nil
        CreateChallengeManager.shared.videoUrl = nil
        
        displayNewChallengePrompt()
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
        
        cameraViewController.view.frame = view.bounds.inset(by: UIEdgeInsets(top: 46, left: 0, bottom: 80, right: 0))
        
        let recordButtonSize: CGFloat = 64
        recordButton.frame = CGRect(
            x: (view.width - recordButtonSize)/2,
            y: cameraViewController.view.bottom - recordButtonSize - 15,
            width: recordButtonSize,
            height: recordButtonSize
        )
    }
    
    // MARK: -
    
    private func displayNewChallengePrompt() {
        let prompt = Prompt()
        prompt.textFieldsRequiredForButton = true
        prompt.tapEscapable = false
        prompt.setTitle(text: "Create Challenge", isGradient: true)
        prompt.addTextInputField(
            placeholderText: "Enter the name of your challenge",
            maxChars: 15,
            numLines: 1,
            font: UIFont(name: "Raleway-Heavy", size: 15)!,
            limitCharacters: [" "]
        )
        prompt.addTextInputField(
            placeholderText: "Write a description for your challenge",
            maxChars: 50,
            numLines: 6
        )
        prompt.addCompletionButton(
            buttonText: "Record",
            textColor: UIColor(named: "XYWhite")!,
            icon: UIImage(systemName: "video.fill"),
            style: .action(style: .roundButton(backgroundColor: .red)),
            font: UIFont(name: "Raleway-Heavy", size: 20),
            closeOnTap: true,
            onTap: nil
        )
        prompt.onCompletion = { inputTexts in
            if let challengeTitle = inputTexts.first, let challengeDescription = inputTexts.last {
                print("Challenge title: \(challengeTitle)")
                print("Description title: \(challengeDescription)")
                
                if challengeTitle == "" || challengeDescription == "" {
                    return
                }
                
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
            HapticsManager.shared.vibrateImpact(for: .medium)
            
            cameraViewController.startRecording()
            recordButton.setState(.recording)
        } else {
            HapticsManager.shared.vibrateImpact(for: .light)
            
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
