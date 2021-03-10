//
//  CameraViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate {
    func cameraViewDidTapCloseButton()
    func didFinishUploadingPost(postData: PostViewModel)
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var delegate: CameraViewControllerDelegate?
    
    private let closeCameraVCButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
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
    
    private var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.mediaTypes = ["public.image", "public.movie"]
        pickerController.videoQuality = .typeHigh
        pickerController.allowsEditing = true
        return pickerController
    }()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
//    var videoOutput : AVCaptureVideoDataOutput?
    
    var backCameraActive = false
    var isFrontRecording = false
    var videoInputBack: AVCaptureDeviceInput?
    var sessionBack: AVCaptureSession?

    var isBackRecording = false
    var videoInputFront: AVCaptureDeviceInput?
    var sessionFront: AVCaptureSession?
    
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(recordButton)
        view.addSubview(openCameraRollButton)
        view.addSubview(closeCameraVCButton)
                
        openCameraRollButton.addTarget(self, action: #selector(didTapCameraRoll), for: .touchUpInside)
        closeCameraVCButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        pickerController.delegate = self
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        recordButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        setupAVCaptureSessions()
        
        if let sessionBack = sessionBack {
            // Set up preview layer and output
            
            previewLayer = AVCaptureVideoPreviewLayer(session: sessionBack)
            view.layer.insertSublayer(previewLayer!, at: 0)
//            videoOutput = AVCaptureVideoDataOutput()
            sessionBack.addOutput(movieFileOutput)
            
            backCameraActive = true

        }
    }

    func setupAVCaptureSessions() {
        
        // Set up back camera

        sessionBack = AVCaptureSession()
        sessionBack!.sessionPreset = .high
        sessionBack!.startRunning()

        let backCamera:AVCaptureDevice? = AVCaptureDevice.default(.builtInDualCamera,
                                                 for: .video, position: .back) ??
            AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video, position: .back)
            
        if let backCamera = backCamera {
            do {
                print("Back camera initialized")
                videoInputBack = try AVCaptureDeviceInput(device: backCamera)
                sessionBack!.addInput(videoInputBack!)
            } catch {
                print("Error initializing session for back input!")
            }
        }
        
        // Set up front camera
        
        sessionFront = AVCaptureSession()
        sessionFront!.sessionPreset = .high
        sessionFront!.startRunning()
        
        let frontCamera:AVCaptureDevice? = AVCaptureDevice.default(.builtInDualCamera,
                                                 for: .video, position: .front) ??
            AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video, position: .front)
            
        if let frontCamera = frontCamera {
            do {
                print("Front camera initialized")
                videoInputFront = try AVCaptureDeviceInput(device: frontCamera)
                sessionFront!.addInput(videoInputFront!)
            } catch {
                print("Error initializing session for back input!")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = view.bounds
    }

    
    override func viewWillAppear(_ animated: Bool) {
        view.setNeedsLayout()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
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
        
        let closeButtonSize: CGFloat = 30
        closeCameraVCButton.frame =  CGRect(
            x: 25,
            y: 50,
            width: closeButtonSize,
            height: closeButtonSize
        )
    }

    // MARK: - Private functions
    
    private func layoutCameraButton() {
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
    
    private func doneAnimation() {
        let doneLabel = UILabel()
        doneLabel.text = "Your Viral has been Uploaded!"
        doneLabel.textColor = .white
        doneLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        doneLabel.layer.shadowRadius = 1.0
        doneLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        doneLabel.sizeToFit()
        
        view.addSubview(doneLabel)
        
        doneLabel.alpha = 0.0
        doneLabel.center = CGPoint(
            x: self.view.center.x,
            y: self.view.height - 100
        )
        
        UIView.animate(withDuration: 0.3) {
            doneLabel.alpha = 1.0
            doneLabel.center = CGPoint(
                x: self.view.center.x,
                y: self.view.center.y - self.view.height / 6
            )
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2, delay: 2.0) {
                    doneLabel.alpha = 0.0
                    doneLabel.center = CGPoint(
                        x: self.view.center.x,
                        y: 0
                    )
                } completion: { (done) in
                    if done {
                        doneLabel.removeFromSuperview()
                    }
                }
            }
        }
    }

    // MARK: - Objc functions
    
    @objc private func didDoubleTap() {
        // Switch cameras
        
        let fromSession = backCameraActive ? sessionBack! : sessionFront!
        let toSession = backCameraActive ? sessionFront! : sessionBack!
        backCameraActive = !backCameraActive
        
        print("Front session: \(sessionFront!)")
        print("Back session: \(sessionFront!)")
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DispatchQueue.main.async {
            fromSession.beginConfiguration()
            fromSession.removeOutput(self.movieFileOutput)
            fromSession.commitConfiguration()
            
            toSession.beginConfiguration()
            if toSession.canAddOutput(self.movieFileOutput) {
                toSession.addOutput(self.movieFileOutput)
                print("Output changed")
            }
            toSession.commitConfiguration()
            
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main, work: DispatchWorkItem(block: {
            let newPreviewLayer = AVCaptureVideoPreviewLayer(session: toSession)
            newPreviewLayer.videoGravity = .resizeAspectFill
            newPreviewLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(newPreviewLayer, at: 0)
            
            self.previewLayer?.removeFromSuperlayer()
            self.previewLayer = newPreviewLayer
        }))
    }
    
    @objc private func didTapRecordButton() {
        if isBackRecording {
            didEndRecording()
            isBackRecording = false
        } else if isFrontRecording {
            didEndRecording()
            isFrontRecording = false
        } else {
            if backCameraActive {
                isBackRecording = true
                didStartRecording()
            } else {
                isFrontRecording = true
                didStartRecording()
            }
        }
    }
    
    @objc private func didTapClose() {
        tabBarController?.selectedIndex = 0
        delegate?.cameraViewDidTapCloseButton()
    }
    
    @objc private func didTapCameraRoll() {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    func didStartRecording() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsURL.appendingPathComponent("tempMovie.mp4")
        if FileManager.default.fileExists(atPath: filePath.absoluteString) {
            do {
                try FileManager.default.removeItem(at: filePath)
            }
            catch {
                // exception while deleting old cached file
                // ignore error if any
            }
        }
        
        movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.recordButton.backgroundColor = .red
        })
    }
    
    func didEndRecording() {
        movieFileOutput.stopRecording()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.recordButton.backgroundColor = UIColor(0x404040)
        })
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let previewVC = PreviewViewController(previewVideoUrl: outputFileURL, delegate: self)
        
        navigationController?.present(previewVC, animated: true, completion: nil)
    }
}

extension CameraViewController : PreviewViewControllerDelegate {
    func didFinishUploadingViral(videoUrl: URL, viralModel: ViralModel) {
        
        previewVC?.dismiss(animated: true) {
            self.doneAnimation()
        }
    }
    
    func didFinishUploadingPost(postData: PostViewModel) {
        self.delegate?.didFinishUploadingPost(postData: postData)
        
        previewVC?.dismiss(animated: true)
    }
}

extension CameraViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pickerController.dismiss(animated: true, completion: nil)
        
        if let image = info[.editedImage] as? UIImage {
            previewVC = PreviewViewController(previewImage: image, delegate: self)
            
            previewVC?.modalPresentationStyle = .fullScreen
            present(previewVC!, animated: true, completion: nil)
        } else if let videoUrl = info[.mediaURL] as? URL {
            previewVC = PreviewViewController(previewVideoUrl: videoUrl, delegate: self)
            
            previewVC?.modalPresentationStyle = .fullScreen
            present(previewVC!, animated: true, completion: nil)
        }
    }
}
