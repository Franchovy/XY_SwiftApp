//
//  CreateChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

let segmentCameraTest = true

class CreateChallengeViewController: UIViewController, CameraContainerDelegate {
    
    var videoURL: URL?
    
    let segmentViewController = SegmentCameraViewController()
    let cameraContainerViewController = CameraContainerViewController()
    
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
        
        if segmentCameraTest {
            view.addSubview(segmentViewController.view)
            addChild(segmentViewController)
        } else {
            view.addSubview(cameraContainerViewController.view)
            addChild(cameraContainerViewController)
            cameraContainerViewController.delegate = self
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if segmentCameraTest {
            segmentViewController.view.frame = view.bounds.inset(by: UIEdgeInsets(top: 46, left: 0, bottom: 80, right: 0))
        } else {
            cameraContainerViewController.view.frame = view.bounds.inset(by: UIEdgeInsets(top: 46, left: 0, bottom: 80, right: 0))
        }
    }
    
    // MARK: - CameraContainerDelegate Functions
    
    func didFinishRecording(videoURL: URL) {
        self.videoURL = videoURL
        
        DispatchQueue.main.async {
            self.displayPreview()
        }
    }
    
    func closeButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private functions
    
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
}
