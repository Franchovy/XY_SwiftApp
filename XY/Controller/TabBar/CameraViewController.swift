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
    func didFinishUploadingPost(postData: PostViewModel)
}

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {

    var delegate: CameraViewControllerDelegate?
    
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

    private var previewVC: PreviewViewController?
    
    private var pickerController: UIImagePickerController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        videoGravity = .resizeAspectFill
        swipeToZoom = false
        pinchToZoom = true
        maximumVideoDuration = 10.0
        
        pickerController = UIImagePickerController()
        
        super.viewDidLoad()
        
        self.pickerController!.delegate = self
        self.pickerController!.allowsEditing = true
    
        view.addSubview(recordButton)
        view.addSubview(openCameraRollButton)
        view.addSubview(closeCameraVCButton)
                
        openCameraRollButton.addTarget(self, action: #selector(didTapCameraRoll), for: .touchUpInside)
        closeCameraVCButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        recordButton.delegate = self
        cameraDelegate = self
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        recordButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.setNeedsLayout()
        
        session.sessionPreset = .high
        session.commitConfiguration()
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabBarController?.setTabBarVisible(visible: false, duration: 0.1, animated: true)

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
        
        let closeButtonSize: CGFloat = 30
        closeCameraVCButton.frame =  CGRect(
            x: 25,
            y: view.safeAreaInsets.top,
            width: closeButtonSize,
            height: closeButtonSize
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
        shape.lineWidth = 10
        shape.path = UIBezierPath(roundedRect: recordButton.bounds, cornerRadius: recordButton.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        recordButton.layer.addSublayer(gradient)
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
        pickerController?.sourceType = .photoLibrary
        present(pickerController!, animated: true, completion: {

            //self.pickerController?.dismiss(animated: true, completion: nil)
        })
    }
    
    
    // MARK: - Delegate methods
    
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController) {
        // Not Authorized to camera or mic (?)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Take Photo
        previewVC = PreviewViewController(previewImage: photo, delegate: self)

        view.addSubview(previewVC!.view)

        previewVC!.view.frame = view.bounds
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
        
        previewVC = PreviewViewController(previewVideoUrl: url, delegate: self)
        
        view.addSubview(previewVC!.view)
        
        previewVC!.view.frame = view.bounds
    }
}

extension CameraViewController : PreviewViewControllerDelegate {
    func didFinishUploadingPost(postData: PostViewModel) {
        self.delegate?.didFinishUploadingPost(postData: postData)

        previewVC?.dismiss(animated: true) {
            self.previewVC?.view.removeFromSuperview()
        }
    }
}

extension CameraViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pickerController?.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        previewVC = PreviewViewController(previewImage: image, delegate: self)
        
        previewVC?.modalPresentationStyle = .fullScreen
        present(previewVC!, animated: true, completion: nil)
    }
}
