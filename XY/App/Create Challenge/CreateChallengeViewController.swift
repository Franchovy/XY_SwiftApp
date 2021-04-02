//
//  CreateChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import CameraManager

class CreateChallengeViewController: UIViewController {
    
    enum CameraState {
        case prepareToRecord
        case recording
        case finishedRecording
    }
    private var state:CameraState = .prepareToRecord
    
    var videoURL: URL?
    
    private let cameraManager = CameraManager()
    private let recordButton = RecordButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        cameraManager.cameraOutputMode = .videoWithMic
        cameraManager.cameraOutputQuality = .high
        
        cameraManager.shouldEnableExposure = false
        cameraManager.exposureMode = .continuousAutoExposure
        
        cameraManager.writeFilesToPhoneLibrary = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.addPreviewLayerToView(view)
        
        presentingViewController?.navigationItem.backButtonTitle = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.xmark)
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayNewChallengePrompt()
        
        view.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    private func startRecording() {
        
    }
    
    private func endRecording() {
        
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
        if state == .prepareToRecord {
            recordButton.setState(.recording)
            cameraManager.startRecordingVideo()
            state = .recording
        } else {
            state = .finishedRecording
            recordButton.setState(.notRecording)
            cameraManager.stopVideoRecording { (videoURL, error) in
                if let error = error {
                    self.displayTempLabel(
                        centerPoint: self.view.center,
                        labelText: error.localizedDescription,
                        labelColor: UIColor(named: "XYWhite")!
                    )
                } else if let videoURL = videoURL {
                    self.videoURL = videoURL
                    DispatchQueue.main.async {
                        self.displayPreview()
                    }
                }
            }
        }
    }
}
