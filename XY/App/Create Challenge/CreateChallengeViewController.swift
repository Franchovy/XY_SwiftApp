//
//  CreateChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import CameraManager

class CreateChallengeViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        cameraManager.cameraOutputMode = .videoWithMic
        cameraManager.cameraOutputQuality = .high
        
        cameraManager.shouldEnableExposure = false
        cameraManager.exposureMode = .continuousAutoExposure
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.addPreviewLayerToView(view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        view.addSubview(prompt)
        
        prompt.appear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

}
