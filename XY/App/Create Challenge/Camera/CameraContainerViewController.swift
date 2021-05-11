//
//  CameraContainerViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/04/2021.
//

import UIKit

protocol CameraContainerDelegate {
    func didFinishRecording(videoURL: URL)
    func closeButtonPressed()
}

class CameraContainerViewController: UIViewController {

    private let cameraViewController = CameraViewController()
    private let switchCameraButton = Button(image: UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal), style: .image)
    private let flashButton = Button(image: UIImage(systemName: "bolt.fill")?.withTintColor(UIColor.yellow, renderingMode: .alwaysOriginal), style: .image)
    private let recordButton = RecordButton()
    private let closeButton = Button(image: UIImage(systemName: "xmark"), style: .image)
    
    var delegate: CameraContainerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cameraViewController.view)
        addChild(cameraViewController)
        
        view.addSubview(switchCameraButton)
        view.addSubview(flashButton)
        view.addSubview(closeButton)
        
        view.addSubview(recordButton)
        
        flashButton.contentEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        switchCameraButton.contentEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(flashButtonPressed), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraButtonPressed), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let closeButtonSize: CGFloat = 20
        closeButton.frame = CGRect(
            x: 10,
            y: 13.35,
            width: closeButtonSize,
            height: closeButtonSize
        )
        
        let switchCameraButtonSize = CGSize(width: 26.25, height: 22.5)
        switchCameraButton.frame = CGRect(
            x: view.width - 9.95 - switchCameraButtonSize.width,
            y: 10.22,
            width: switchCameraButtonSize.width,
            height: switchCameraButtonSize.height
        )
        
        let flashButtonSize = CGSize(width: 15, height: 26.26)
        flashButton.frame = CGRect(
            x: switchCameraButton.center.x - flashButtonSize.width/2,
            y: switchCameraButton.bottom + 15,
            width: flashButtonSize.width,
            height: flashButtonSize.height
        )
        
        let recordButtonSize: CGFloat = 64
        recordButton.frame = CGRect(
            x: (view.width - recordButtonSize)/2,
            y: cameraViewController.view.bottom - recordButtonSize - 15,
            width: recordButtonSize,
            height: recordButtonSize
        )
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
                self.delegate?.didFinishRecording(videoURL: outputUrl)
            }
        }
    }
    
    @objc private func flashButtonPressed() {
        cameraViewController.toggleFlash()
    }
    
    @objc private func switchCameraButtonPressed() {
        cameraViewController.switchCamera()
    }

    @objc private func closeButtonPressed() {
        CreateChallengeManager.shared.clearData()
        
        delegate?.closeButtonPressed()
    }
}
