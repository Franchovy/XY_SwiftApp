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

protocol StartChallengeDelegate {
    func pressedPlay(challenge: ChallengeViewModel)
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
    
    private var countDownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 105)
        label.textColor = UIColor(named: "XYWhite")
        label.text = " "
        label.alpha = 0.0
        return label
    }()
    
    private var challengeTimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 44)
        label.textColor = UIColor(0xF2EF37)
        label.text = " "
        label.isHidden = true
        return label
    }()
    
    private let switchCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camera_switchcamera_icon"), for: .normal)
        return button
    }()
    
    private let flashCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camera_flash_icon"), for: .normal)
        return button
    }()
    
    private var challengeTitleLabel: GradientLabel?
    static var challengeCardSize = CGSize(width: 118*1.4, height: 170*1.4)

    private let nextButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Upload", for: .normal)
        button.setTitleColor(UIColor(named: "XYWhite")!, for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setGradient(Global.xyGradient)
        button.isHidden = true
        return button
    }()
    
    private let retakeButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(UIColor(named: "XYWhite")!, for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setBackgroundColor(color: UIColor(named: "XYBlack-1")!)
        button.setGradient(Global.xyGradient)
        button.isHidden = true
        return button
    }()
    
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
    
    var outputVideoURL: URL?
    var readyToPresentPreview = false
    
    var flashEnabled = false
    
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
    var activeChallenge: ChallengeViewModel?
    
    weak var timer: Timer?
    var startTime: Double = 0
    var endTime: Date?
    var time: Double = 0
    
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
        
        view.addSubview(flashCameraButton)
        view.addSubview(switchCameraButton)
        
        view.addSubview(recordButton)
        view.addSubview(closeCameraVCButton)
        view.addSubview(challengePreviewCollectionView)
        
        view.addSubview(challengeTimerLabel)
        view.addSubview(countDownLabel)
        
        view.addSubview(nextButton)
        view.addSubview(retakeButton)
        
        switchCameraButton.addTarget(self, action: #selector(didDoubleTap), for: .touchUpInside)
        flashCameraButton.addTarget(self, action: #selector(didTapFlash), for: .touchUpInside)
        closeCameraVCButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        retakeButton.addTarget(self, action: #selector(didTapRetake), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
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
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        
        switchCameraButton.frame = CGRect(
            x: view.width - 26.25 - 26.63,
            y: 60.98,
            width: 26.25,
            height: 22.5
        )
        
        flashCameraButton.frame = CGRect(
            x: switchCameraButton.left - 26.26 - 22.12,
            y: switchCameraButton.top,
            width: 15,
            height: 26.26
        )
        
        layoutChallengeTimerLabel()
        
        layoutCountDownLabel()
        
        layoutCameraButton()
        
        let closeButtonSize: CGFloat = 30
        closeCameraVCButton.frame =  CGRect(
            x: 10.42,
            y: 63.73,
            width: closeButtonSize,
            height: closeButtonSize
        )
        
        let buttonSize = CGSize(width: 241, height: 54)
        
        retakeButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: view.height/2 - buttonSize.height - 15,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        nextButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: retakeButton.top - buttonSize.height - 28,
            width: buttonSize.width,
            height: buttonSize.height
        )
        nextButton.layer.cornerRadius = buttonSize.height / 2
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
                creator: ProfileModel(profileId: "", nickname: "Simone", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: ""),
                timeInMinutes: 3.0
            ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "RunToTheTop",
                description: "Run to the top of a mountain",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Maxime", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: ""),
                timeInMinutes: 4.0
            ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "5AM",
                description: "Be outside your own door at 5AM",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Maxime", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: ""),
                timeInMinutes: 1.0
            ),
            ChallengeViewModel(
                id: "",
                videoUrl: URL(fileURLWithPath: ""),
                title: "ColorTheFace",
                description: "Draw on the face of your CTO while he meditates",
                gradient: Global.xyGradient,
                creator: ProfileModel(profileId: "", nickname: "Simone", profileImageId: "", coverImageId: "", website: "", followers: 0, following: 0, swipeRights: 0, xp: 0, level: 0, caption: ""),
                timeInMinutes: 2.0
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
    
    private func layoutCountDownLabel() {
        countDownLabel.sizeToFit()
        countDownLabel.frame = CGRect(
            x: (view.width - countDownLabel.width)/2,
            y: (view.height - countDownLabel.height)/2,
            width: countDownLabel.width,
            height: countDownLabel.height
        )
    }
    
    private func layoutChallengeTimerLabel() {
        challengeTimerLabel.sizeToFit()
        challengeTimerLabel.frame = CGRect(
            x: (view.width - challengeTimerLabel.width)/2,
            y: 32,
            width: challengeTimerLabel.width,
            height: challengeTimerLabel.height
        )
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
    
    private func startRecording() {
        
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
        
        if backCameraActive {
            isBackRecording = true
        } else {
            isFrontRecording = true
        }
//        movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.recordButton.backgroundColor = .red
        })
    }
    
    private func didEndRecording() {
        timer?.invalidate()
        
        movieFileOutput.stopRecording()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.recordButton.backgroundColor = UIColor(0x404040)
        })
    }
    
    internal func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        outputVideoURL = outputFileURL
        
        if readyToPresentPreview {
            presentPreviewController()
        }
    }
    
    private func setUpForChallenge(challenge: ChallengeViewModel) {
        
        activeChallenge = challenge
        
        prepareToRecord()
    }
    
    private func prepareToRecord() {
        
        // Start timer
        countDownLabel.isHidden = false
        var countDown = 3
        UIView.animate(withDuration: 0.3) {
            self.countDownLabel.alpha = 1.0
            self.challengePreviewCollectionView.frame.origin.y = self.view.height
        } completion: { (done) in
            if done {
                self.challengePreviewCollectionView.isHidden = true
                
                self.recursiveCountDown(count: countDown) {
                    self.startRecording()
                    self.countDownLabel.alpha = 0.0
                    self.challengeTimerLabel.isHidden = false
                    self.startTimer(lengthInMinutes: 1)
                }
            }
        }
    }
    
    private func recursiveCountDown(count: Int, completion: @escaping() -> Void) {
        if count != 0 {
            countDownLabel.text = String(describing: count)
            layoutCountDownLabel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.recursiveCountDown(count: count - 1, completion: completion)
            }
        } else {
            completion()
        }
    }
    
    private func startTimer(lengthInMinutes: Float) {
        startTime = Date().timeIntervalSinceReferenceDate
        print("Start time: \(startTime)")
        endTime = Date().addingTimeInterval(Double(lengthInMinutes * 60))
        print("End time: \(endTime)")
        
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func advanceTimer(timer: Timer) {
        //Total time since timer started, in seconds
        time = endTime!.timeIntervalSince(Date())
        
        let ti = NSInteger(time)
        
        if ti < 0 {
            challengeTimerLabel.text = "00:00.00"
            finishedRecording()
        } else {
            let ms = Int(time.truncatingRemainder(dividingBy: 1) * 100)
            
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            
            //Display the time string to a label in our view controller
            challengeTimerLabel.text = "\(minutes):\(seconds).\(ms)"
        }
        layoutChallengeTimerLabel()
    }

    private func finishedRecording() {
        didEndRecording()
        
        retakeButton.isHidden = false
        nextButton.isHidden = false
    }
    
    private func presentPreviewController() {
        guard let outputVideoURL = outputVideoURL else {
            return
        }
        
        let previewVC = PreviewViewController(previewVideoUrl: outputVideoURL, delegate: self)
        navigationController?.present(previewVC, animated: true, completion: nil)
    }
    
    // MARK: - Obj-C functions
    
    @objc private func didTapNext() {
        readyToPresentPreview = true
        
        if outputVideoURL != nil {
            presentPreviewController()
        }
    }
    
    @objc private func didTapRetake() {
        self.challengeTimerLabel.isHidden = true
        self.challengePreviewCollectionView.isHidden = false
        self.challengePreviewCollectionView.frame.origin.y = self.view.height
        UIView.animate(withDuration: 0.3) {
            self.challengePreviewCollectionView.frame.origin.y = self.recordButton.top - CameraViewController.challengeCardSize.height - 20
            self.retakeButton.frame.origin.x = -self.view.width
            self.nextButton.frame.origin.x = self.view.width
        } completion: { (done) in
            if done {
                self.retakeButton.isHidden = true
                self.nextButton.isHidden = true
            }
        }
    }
    
    @objc private func didTapFlash() {
        flashEnabled = !flashEnabled
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
                do {
                    try device.lockForConfiguration()

                    device.torchMode = flashEnabled ? .on : .off
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            } else {
                print("Torch is not available")
            }
    }
    
    @objc private func didDoubleTap() {
        guard !isFrontRecording && !isBackRecording else {
            let messageLabel = UILabel()
            messageLabel.font = UIFont(name: "Raleway-Medium", size: 16)
            messageLabel.text = "Sorry, you can't flip the camera yet!"
            messageLabel.sizeToFit()
            messageLabel.alpha = 0
            view.addSubview(messageLabel)
            messageLabel.center = view.center
            UIView.animate(withDuration: 0.3) {
                messageLabel.alpha = 1.0
            } completion: { (done) in
                if done {
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        messageLabel.removeFromSuperview()
                    }
                }
            }
            return
        }
        
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
            finishedRecording()
            isBackRecording = false
        } else if isFrontRecording {
            finishedRecording()
            isFrontRecording = false
        } else {
            if backCameraActive {
                startRecording()
            } else {
                startRecording()
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
        
        cell.challengeStartDelegate = self
        cell.configure(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension CameraViewController : StartChallengeDelegate {
    func pressedPlay(challenge: ChallengeViewModel) {
        setUpForChallenge(challenge: challenge)
    }
}
