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

protocol StartChallengeDelegate {
    func pressedPlay(challenge: ChallengeViewModel)
}

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
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
        button.isEnabled = false
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
    
    private let newChallengeButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Create New", for: .normal)
        button.setTitleColor(UIColor(named: "XYWhite")!, for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setBackgroundColor(color: UIColor(named: "XYBlack-1")!)
        button.setGradient(Global.xyGradient)
        return button
    }()

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
        collectionView.clipsToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.register(ChallengePreviewCollectionViewCell.self, forCellWithReuseIdentifier: ChallengePreviewCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var previewVC: PreviewViewController?
    
    var readyToPresentPreview = false
    
    var backCameraActive = true
    var isFrontRecording = false
    var isBackRecording = false
    var outputVideoURL: URL?
    
    var viewModels = [ChallengeViewModel]()
    var activeChallenge: ChallengeViewModel?
    
    var collectionViewY: CGFloat!
    var createNewButtonY: CGFloat!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displaySuggestedChallenges()
        
        outputVideoURL = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraDelegate = self
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(flashCameraButton)
        view.addSubview(switchCameraButton)
        view.addSubview(recordButton)
        view.addSubview(closeCameraVCButton)
        
        view.addSubview(newChallengeButton)
        view.addSubview(challengePreviewCollectionView)
        
        view.addSubview(challengeTimerLabel)
        view.addSubview(countDownLabel)
        
        view.addSubview(nextButton)
        view.addSubview(retakeButton)
                
        newChallengeButton.addTarget(self, action: #selector(didTapCreateNewChallenge), for: .touchUpInside)
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
        
        challengePreviewCollectionView.dataSource = self
        fetchChallenges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
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
        
        let newChallengeButtonSize = CGSize(width: 259, height: 54)
        if createNewButtonY == nil {
            createNewButtonY = -100
        }
        newChallengeButton.frame = CGRect(
            x: (view.width - newChallengeButtonSize.width)/2,
            y: createNewButtonY,
            width: newChallengeButtonSize.width,
            height: newChallengeButtonSize.height
        )
        
        if collectionViewY == nil {
            collectionViewY = view.height
        }
        challengePreviewCollectionView.frame = CGRect(
            x: 0,
            y: collectionViewY,
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
            x: switchCameraButton.left - 26.26 - 12.12,
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
        viewModels = []
        
        ChallengesFirestoreManager.shared.getChallenges { (challengeModels) in
            if let challengeModels = challengeModels {
                let group = DispatchGroup()
                
                for challengeModel in challengeModels {
                    group.enter()
                    
                    ChallengesViewModelBuilder.build(from: challengeModel) { (challengeViewModel) in
                        defer {
                            group.leave()
                        }
                        if let challengeViewModel = challengeViewModel {
                            self.viewModels.append(challengeViewModel)
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.displaySuggestedChallenges()
                }
            }
        }
    }
    
    private func displaySuggestedChallenges() {
        guard activeChallenge == nil else {
            return
        }
        
        challengePreviewCollectionView.reloadData()
        
        newChallengeButton.frame.origin.y = -100
        challengePreviewCollectionView.frame.origin.y = view.height
        UIView.animate(withDuration: 0.3) {
            self.challengePreviewCollectionView.frame.origin.y = self.view.height/2 + 25
            self.newChallengeButton.frame.origin.y = (self.view.height - 54)/4
        } completion: { (done) in
            if done {
                self.collectionViewY = self.view.height/2 + 25
                self.createNewButtonY = (self.view.height - 54)/4
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

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
         outputVideoURL = url
    }
    
    private func startRecording() {
        startVideoRecording()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.recordButton.backgroundColor = .red
        })
    }
    
    private func didEndRecording() {
        timer?.invalidate()
        
        stopVideoRecording()
        
        recordButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.recordButton.backgroundColor = UIColor(0x404040)
        })
    }
    
    private func setUpForChallenge(challenge: ChallengeViewModel) {
        activeChallenge = challenge
        recordButton.isEnabled = true
        prepareToRecord(withChallengeLengthInMinutes: 0.5)
    }
    
    private func prepareToRecord(withChallengeLengthInMinutes lengthInMinutes: Float) {
        // Start timer
        countDownLabel.isHidden = false
        countDownLabel.text = "3"
        layoutCountDownLabel()
        var countDown = 3
        collectionViewY = self.view.height
        createNewButtonY = -100
        
        setTimerText(timeInteger: NSInteger(TimeInterval(lengthInMinutes * 60)))
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn) {
            self.countDownLabel.alpha = 1.0
            self.challengePreviewCollectionView.frame.origin.y = self.view.height
            self.newChallengeButton.frame.origin.y = -100
            
        } completion: { (done) in
            if done {
                self.challengeTimerLabel.isHidden = false
                self.challengeTimerLabel.frame.origin.y = -50
                
                UIView.animate(withDuration: 0.3, delay: 2.0) {
                    self.challengeTimerLabel.frame.origin.y = 32
                }
                
                self.challengePreviewCollectionView.isHidden = true
                self.newChallengeButton.isHidden = true
                
                self.recursiveCountDown(count: countDown) {
                    self.startRecording()
                    self.countDownLabel.alpha = 0.0
                    self.startTimer(lengthInMinutes: lengthInMinutes)
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
        endTime = Date().addingTimeInterval(Double(lengthInMinutes * 60))
        
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
            setTimerText(timeInteger: ti, ms: ms)
        }
        layoutChallengeTimerLabel()
    }

    private func setTimerText(timeInteger: NSInteger, ms: NSInteger = 0) {
        
        let seconds = timeInteger % 60
        let minutes = (timeInteger / 60) % 60
        
        //Display the time string to a label in our view controller
        challengeTimerLabel.text = String(format: "%02d:%02d.%02d", minutes, seconds, ms)
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
        
        let previewVC = PreviewViewController(previewVideoUrl: outputVideoURL)
        
        if activeChallenge != nil {
            previewVC.configure(with: activeChallenge!)
        } else {
            previewVC.configureWithNewChallenge()
        }
        
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    private func reset() {
        if isBackRecording || isFrontRecording {
            didEndRecording()
        }
        
        self.challengeTimerLabel.isHidden = true
        self.challengePreviewCollectionView.isHidden = false
        self.newChallengeButton.isHidden = false
        
        self.challengePreviewCollectionView.frame.origin.y = self.view.height
        self.newChallengeButton.frame.origin.y = -100
        
        UIView.animate(withDuration: 0.3) {
            self.challengePreviewCollectionView.frame.origin.y = self.recordButton.top - CameraViewController.challengeCardSize.height - 20
            self.newChallengeButton.frame.origin.y = (self.view.height - 54)/4
            self.retakeButton.frame.origin.x = -self.view.width
            self.nextButton.frame.origin.x = self.view.width
        } completion: { (done) in
            if done {
                self.createNewButtonY = (self.view.height - 54)/4
                self.collectionViewY = self.recordButton.top - CameraViewController.challengeCardSize.height - 20
                self.retakeButton.isHidden = true
                self.nextButton.isHidden = true
            }
        }
    }
    
    // MARK: - Obj-C functions
    
    @objc private func didTapCreateNewChallenge() {
        recordButton.isEnabled = true
        prepareToRecord(withChallengeLengthInMinutes: 0.5)
    }
    
    @objc private func didTapNext() {
        readyToPresentPreview = true
        
        if outputVideoURL != nil {
            presentPreviewController()
        }
    }
    
    @objc private func didTapRetake() {
        reset()
    }
    
    var flashOn = false
    @objc private func didTapFlash() {
        flashMode = flashOn ? .on : .off
        flashOn = !flashOn
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
        
        switchCamera()
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
        if isBackRecording || isFrontRecording {
            // Add popup View
            let popupView = PopupWarningView(
                title: "Quit Challenge?",
                buttonText: "Quit 😢",
                completion: {
                    self.tabBarController?.selectedIndex = 0
                    self.delegate?.cameraViewDidTapCloseButton()
                }
            )
            
            popupView.sizeToFit()
            self.view.addSubview(popupView)
            popupView.center = self.view.center
        } else {
            self.tabBarController?.selectedIndex = 0
            self.delegate?.cameraViewDidTapCloseButton()
        }
    }
}

extension CameraViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChallengePreviewCollectionViewCell.identifier,
                for: indexPath
        ) as? ChallengePreviewCollectionViewCell else {
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
