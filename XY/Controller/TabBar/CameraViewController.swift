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
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(0xb9b9b9)
        return button
    }()
    
    static var challengeCardSize = CGSize(width: 118*1.4, height: 170*1.4)
    
    private let challengePreviewCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = challengeCardSize
    
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.register(ChallengePreviewCollectionViewCell.self, forCellWithReuseIdentifier: ChallengePreviewCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private var previewVC: PreviewViewController?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var backCameraActive = false
    var isFrontRecording = false
    var videoInputBack: AVCaptureDeviceInput?
    var sessionBack: AVCaptureSession?

    var isBackRecording = false
    var videoInputFront: AVCaptureDeviceInput?
    var sessionFront: AVCaptureSession?
    
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    var viewModels = [ChallengeViewModel]()
    
    // MARK: - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(recordButton)
        view.addSubview(closeCameraVCButton)
        view.addSubview(challengePreviewCollectionView)
                
        closeCameraVCButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
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
            sessionBack.addOutput(movieFileOutput)
            
            backCameraActive = true
        }
        
        challengePreviewCollectionView.dataSource = self
        fetchChallenges()
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
        
        challengePreviewCollectionView.frame = CGRect(
            x: 0,
            y: recordButton.top - CameraViewController.challengeCardSize.height - 20,
            width: view.width,
            height: CameraViewController.challengeCardSize.height
        )
        
        layoutCameraButton()
        
        let closeButtonSize: CGFloat = 30
        closeCameraVCButton.frame =  CGRect(
            x: 10.42,
            y: 63.73,
            width: closeButtonSize,
            height: closeButtonSize
        )
    }

    // MARK: - Private functions
    
    private func fetchChallenges() {
        
        viewModels = [
        ChallengeViewModel(
            id: "",
            videoUrl: URL(fileURLWithPath: ""),
            title: "HelpGrandma",
            description: "Take a grandma by the arm and help her across the street",
            gradient: Global.xyGradient,
            creator: ProfileModel(profileId: "", nickname: "Simone", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: "")
        ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "RunToTheTop",
                description: "Run to the top of a mountain",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Maxime", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: "")
            ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "5AM",
                description: "Be outside your own door at 5AM",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Maxime", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: "")
            ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "ColorTheFace",
                description: "Draw on the face of your CTO while he meditates",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Simone", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: "")
            ),
        ]
        
        challengePreviewCollectionView.reloadData()
    }
    
    private func setupAVCaptureSessions() {
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
    
    private func layoutCameraButton() {
        recordButton.layer.cornerRadius = recordButton.width / 2
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: recordButton.frame.size)
        gradient.colors = [
            UIColor.lightGray.cgColor,
            UIColor.lightGray.cgColor  
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
    
    private func didStartRecording() {
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
    
    private func didEndRecording() {
        movieFileOutput.stopRecording()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.recordButton.backgroundColor = UIColor(0x404040)
        })
    }
    
    internal func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let previewVC = PreviewViewController(previewVideoUrl: outputFileURL, delegate: self)
        
        navigationController?.present(previewVC, animated: true, completion: nil)
    }

    // MARK: - Obj-C functions
    
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

extension CameraViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengePreviewCollectionViewCell.identifier, for: indexPath) as? ChallengePreviewCollectionViewCell else {
            return UICollectionViewCell()
        }
        print("Configure: \(viewModels[indexPath.row].title)")
        cell.configure(viewModel: viewModels[indexPath.row])
        return cell
    }
}
