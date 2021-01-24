//
//  CameraViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit
import AVFoundation
import SwiftyCam

protocol CameraViewControllerDelegate {
    func cameraViewDidTapCloseButton()
}

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    var delegate: CameraViewControllerDelegate?
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "chevron.right.circle"), for: .normal)
        button.tintColor = .green
        return button
    }()
    
    private let closePreviewButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .red
        return button
    }()
    
    private let closeCameraVCButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let recordButton: SwiftyCamButton = {
        let button = SwiftyCamButton()
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(0xb9b9b9)
        
        return button
    }()
    
    private let openCameraRollButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.tintColor = .white
        return button
    }()
        
    private var playerDidFinishObserver: NSObjectProtocol?
    private var previewLayerView = UIView()
    private var previewLayer: AVPlayerLayer?
    private var recordedVideoUrl: URL?

    private var previewMode = false {
        didSet {
            recordButton.isHidden = previewMode
            closeCameraVCButton.isHidden = previewMode
            openCameraRollButton.isHidden = previewMode
            closePreviewButton.isHidden = !previewMode
            nextButton.isHidden = !previewMode
        }
    }
    
    private let blurMenu: BlurMenuViewController = {
        let blurMenu = BlurMenuViewController()
        return blurMenu
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        videoGravity = .resizeAspectFill
        pinchToZoom = true
        maximumVideoDuration = 10.0
        
        super.viewDidLoad()
    
        view.addSubview(previewLayerView)
        view.addSubview(recordButton)
        view.addSubview(openCameraRollButton)
        view.addSubview(closeCameraVCButton)
        view.addSubview(nextButton)
        view.addSubview(closePreviewButton)

        
        blurMenu.delegate = self
        
        previewMode = false
        
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        closePreviewButton.addTarget(self, action: #selector(didTapClosePreview), for: .touchUpInside)
        openCameraRollButton.addTarget(self, action: #selector(didTapCameraRoll), for: .touchUpInside)
        closeCameraVCButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        recordButton.delegate = self
        cameraDelegate = self
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
     
    }
    
    override func viewWillLayoutSubviews() {
        tabBarController?.setTabBarVisible(visible: false, duration: 0.1, animated: true)
        blurMenu.view.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(blurMenu.view)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        let recordButtonSize: CGFloat = 60
        recordButton.frame = CGRect(
            x: (view.width - recordButtonSize)/2,
            y: view.bottom - 25 - recordButtonSize,
            width: recordButtonSize,
            height: recordButtonSize
        )
        
        layoutCameraButton()
        
        let openCameraRollButtonSize: CGFloat = 35
        openCameraRollButton.frame = CGRect(
            x: 25,
            y: view.bottom - 25 - openCameraRollButtonSize,
            width: openCameraRollButtonSize,
            height: openCameraRollButtonSize
        )
        
        closeCameraVCButton.frame = CGRect(
            x: 25,
            y: view.top + 25 + 30,
            width: 30,
            height: 30
        )
        
        previewLayerView.frame = view.bounds
        
        layoutPreviewButtons()
    }
    
    func layoutPreviewButtons() {
        let size: CGFloat = 45
        
        nextButton.frame = CGRect(
            x: view.right - 25 - size,
            y: view.top + 25,
            width: size,
            height: size
        )
                
        closePreviewButton.frame = CGRect(
            x: 25,
            y: view.top + 25,
            width: size,
            height: size
        )
    }
    
    func layoutCameraButton() {
        recordButton.layer.cornerRadius = recordButton.width / 2
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: recordButton.frame.size)
        gradient.colors = [
            UIColor(0x0C98F6).cgColor, // XYBlue
            UIColor(0xFF0062).cgColor  // XYPink
        ]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 7
        shape.path = UIBezierPath(roundedRect: recordButton.bounds, cornerRadius: recordButton.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        recordButton.layer.addSublayer(gradient)
    }

    
    public func setCloseButtonVisible(_ isVisible: Bool) {
        closeCameraVCButton.isHidden = !isVisible
    }

    // MARK: - Objc functions
    
    @objc private func didDoubleTap() {
        switchCamera()
    }
    
    @objc private func didTapRecordButton() {
        takePhoto()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
        
        delegate?.cameraViewDidTapCloseButton()
    }
    
    @objc private func didTapCameraRoll() {
        
    }
            
    @objc private func didTapNextButton() {
        // Upload video
        
        guard let url = recordedVideoUrl else {
            return
        }
        
        FirebaseUpload.uploadVideo(with: url) { [weak self] (result) in
            switch result {
            case .success(let uploadedPath):
                print("Uploaded video with path: \(uploadedPath)")
                
                FirebaseUpload.createMoment(caption: "This is our first moment", videoPath: uploadedPath) { result in
                    switch result {
                    case .success(let momentId):
                        print("Uploaded moment document with id: \(momentId)")
                    case .failure(let error):
                        print("Error uploading moment document: \(error)")
                    }
                }
                
                // Close vc, open moment
                self?.didTapClosePreview()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func didTapClosePreview() {
        previewLayer?.removeFromSuperlayer()
        previewMode = false
    }
    
    
    // MARK: - Delegate methods
    
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController) {
        // Not Authorized to camera or mic (?)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Take Photo
        
        FirebaseUpload.createPost(caption: "Here's a post", image: photo) { (result) in
            switch result {
            case .failure(let error):
                break
            case .success(let postModel):
                break
            }
        }
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Start Recording Video
        
        UIView.animate(withDuration: 0.3, animations: {
            self.recordButton.backgroundColor = .red
        })
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // End Recording Video
        
        UIView.animate(withDuration: 0.5, animations: {
            self.recordButton.backgroundColor = UIColor(0x404040)
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // End Processing Video
        print("Finished processing")
        
        let player = AVPlayer(url: url)
        previewLayer = AVPlayerLayer(player: player)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        guard let previewLayer = previewLayer else { return }
        
        previewLayerView.layer.addSublayer(previewLayer)
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        previewLayer.player?.play()
        previewMode = true
        
        recordedVideoUrl = url
    }
}

extension CameraViewController : BlurMenuViewControllerDelegate {
    func blurMenuViewControllerDelegate(blurMenu: BlurMenuViewController, onButtonSelected: ButtonType) {
        switch onButtonSelected {
        case .moment:
            session.sessionPreset = .high
            session.startRunning()
        case .post:
            
            session.startRunning()
        }
        
        
        blurMenu.dismissAnimated()
        self.blurMenu.view.removeFromSuperview()
    }
}
