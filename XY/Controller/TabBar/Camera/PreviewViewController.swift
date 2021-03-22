//
//  PreviewViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/01/2021.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController, UITextViewDelegate {
        
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.setTitle("Post", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
        return button
    }()
    
    private let closePreviewButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
        return button
    }()
    
    private var challengeTitleLabel: GradientLabel?
    private let challengeTitleTextField: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "Dark")
        textView.layer.cornerRadius = 5
        textView.font = UIFont(name: "Raleway-Regular", size: 12)
        textView.textColor = UIColor(named: "Dark")
        return textView
    }()
    
    private let challengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size: 12)
        label.textColor = UIColor(named: "XYTint")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var captionTextFieldDidBeginEditing = false
    private let captionTextField: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "Dark")
        textView.layer.cornerRadius = 5
        textView.font = UIFont(name: "Raleway-Regular", size: 12)
        textView.textColor = UIColor(named: "XYTint")
        return textView
    }()
    
    private let caption: MessageView = {
        let caption = MessageView()
        caption.text = "Write your caption here"
        caption.frame.size.width = 200
        caption.setColor(.blue)
        caption.isEditable = true
        return caption
    }()
    
    private let maxCharsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size:8)
        label.textColor = UIColor(named: "XYTint")
        label.alpha = 0.5
        return label
    }()
    
    var challengeViewModel: ChallengeViewModel?
    
    private var playerDidFinishObserver: NSObjectProtocol?
    private var previewLayerView = UIView()
    private var previewLayer: AVPlayerLayer?
    
    private var recordedVideoUrl: URL?
    private var previewImageView: UIImageView?
    
    //MARK: - Init
    
    init(previewVideoUrl: URL) {
        super.init(nibName: nil, bundle: nil)
        
        let player = AVPlayer(url: previewVideoUrl)
        player.volume = 0.0
        previewLayer = AVPlayerLayer(player: player)
        previewLayer?.videoGravity = .resizeAspectFill
        
        guard let previewLayer = previewLayer else { return }
        
        previewLayerView.layer.addSublayer(previewLayer)
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        recordedVideoUrl = previewVideoUrl
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapVideo))
        previewLayerView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        
        if let previewImageView = previewImageView {
            view.addSubview(previewImageView)
            
            view.addSubview(caption)
            
        } else {
            navigationController?.isNavigationBarHidden = false
            
            view.addSubview(captionTextField)
            captionTextField.delegate = self
            
            view.addSubview(challengeTitleTextField)
            challengeTitleTextField.delegate = self
            
            view.addSubview(maxCharsLabel)
            view.addSubview(challengeDescriptionLabel)
            view.addSubview(previewLayerView)
        }
        
        view.addSubview(nextButton)
        view.addSubview(closePreviewButton)
        
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        closePreviewButton.addTarget(self, action: #selector(didTapClosePreview), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCaptionView))
        caption.addGestureRecognizer(tapGestureRecognizer)
        
        let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere))
        view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutPreviewButtons()
        
        if previewImageView != nil {
            
            var captionY:CGFloat = 0
            
            if let previewImageView = previewImageView, let previewImage = previewImageView.image {
                previewImageView.layer.cornerRadius = 15
                previewImageView.layer.masksToBounds = true
                
                let imageSize = previewImage.size
                let aspectRatio = imageSize.height / imageSize.width
                let imageHeight = imageSize.height / imageSize.width * view.width
                previewImageView.frame = CGRect(
                    x: view.left,
                    y: (view.height - imageHeight)/2,
                    width: view.width,
                    height: imageHeight
                )
                
                captionY = min(
                    previewImageView.bottom + 10,
                    view.height - caption.height - view.safeAreaInsets.bottom - 10
                )
            } else {
                captionY = view.height - caption.height - view.safeAreaInsets.bottom - 10
            }
            
            caption.frame = CGRect(
                x: 10,
                y: captionY,
                width: caption.width,
                height: caption.height
            )
        } else {
            previewLayerView.frame = CGRect(
                x: 10,
                y: nextButton.bottom + 10,
                width: 100,
                height: 155
            )
            previewLayer?.frame = previewLayerView.bounds
            
            guard let challengeTitleLabel = challengeTitleLabel else {
                return
            }
            
            if challengeViewModel == nil {
                // Configure for enter challenge name
                layoutInputFieldsForNewChallenge()
            } else {
                // Configure for existing challenge name
                layoutInputFieldsForExistingChallenge()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let previewLayer = previewLayer {
            previewLayer.player?.play()
        }
    }
    
    // MARK: - Public functions
    
    public func configure(with viewModel: ChallengeViewModel) {
        challengeViewModel = viewModel
        
        challengeTitleLabel = GradientLabel(text: "#\(viewModel.title)", fontSize: 26, gradientColours: Global.xyGradient)
        challengeTitleLabel!.label.textAlignment = .center
        view.addSubview(challengeTitleLabel!)
        
        challengeTitleTextField.isHidden = true
        challengeDescriptionLabel.text = viewModel.description
        
        captionTextField.text = "Write your caption here..."
        
        layoutInputFieldsForExistingChallenge()
    }
    
    public func configureWithNewChallenge() {
        challengeTitleLabel = GradientLabel(text: "#ChallengeName", fontSize: 26, gradientColours: Global.xyGradient)
        challengeTitleLabel!.label.textAlignment = .center
        challengeTitleLabel!.alpha = 0.5
        view.addSubview(challengeTitleLabel!)
        maxCharsLabel.text = "max. 15 chars"
        
        captionTextField.text = "Write a short description for your challenge here..."
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedToEditChallengeName))
        maxCharsLabel.addGestureRecognizer(tapGesture)
        challengeTitleLabel?.addGestureRecognizer(tapGesture)
        
        layoutInputFieldsForNewChallenge()
    }
    
    // MARK: - Private functions
    
    private func layoutInputFieldsForExistingChallenge() {
        guard let challengeTitleLabel = challengeTitleLabel else {
            return
        }
        
        challengeTitleLabel.frame = CGRect(
            x: previewLayerView.right + 10,
            y: previewLayerView.top,
            width: view.width - previewLayerView.right - 33,
            height: 26
        )
        challengeTitleLabel.setResizesToWidth(width: view.width - previewLayerView.right - 33)
        
        challengeDescriptionLabel.frame = CGRect(
            x: previewLayerView.right + 10,
            y: challengeTitleLabel.bottom + 15,
            width: view.width - previewLayerView.right - 33,
            height: 80
        )
        
        captionTextField.frame = CGRect(
            x: previewLayerView.right + 18,
            y: challengeDescriptionLabel.bottom + 10,
            width: view.width - previewLayerView.right - 33,
            height: 73
        )
    }
    
    private func layoutInputFieldsForNewChallenge() {
        guard let challengeTitleLabel = challengeTitleLabel else {
            return
        }
        challengeTitleTextField.frame = CGRect(
            x: previewLayerView.right + 18,
            y: previewLayerView.top,
            width: view.width - previewLayerView.right - 33,
            height: 73
        )
        challengeTitleLabel.setResizesToWidth(width: view.width - previewLayerView.right - 33)
        challengeTitleLabel.frame = CGRect(
            x: challengeTitleTextField.left,
            y: challengeTitleTextField.top - 15 + (challengeTitleTextField.height - 26) / 2,
            width: view.width - previewLayerView.right - 33,
            height: 26
        )
        
        captionTextField.frame = CGRect(
            x: previewLayerView.right + 18,
            y: challengeTitleTextField.bottom + 10,
            width: view.width - previewLayerView.right - 33,
            height: 73
        )
        
        maxCharsLabel.sizeToFit()
        maxCharsLabel.frame = CGRect(
            x: challengeTitleTextField.left + (challengeTitleTextField.width - maxCharsLabel.width)/2,
            y: challengeTitleTextField.bottom - 19,
            width: maxCharsLabel.width,
            height: maxCharsLabel.height
        )
    }
    
    private func layoutPreviewButtons() {
        let size = CGSize(width: 150, height: 35)
        
        nextButton.sizeToFit()
        nextButton.frame = CGRect(
            x: view.right - 25 - nextButton.width,
            y: view.top + 25 + view.safeAreaInsets.top,
            width: nextButton.width,
            height: nextButton.height
        )
        
        closePreviewButton.sizeToFit()
        closePreviewButton.frame = CGRect(
            x: 25,
            y: view.top + 25 + view.safeAreaInsets.top,
            width: closePreviewButton.width,
            height: closePreviewButton.height
        )
    }
    
    var textToDisplay: String?
    private func displayTemporaryLabel(text: String) {
        print(text)
        
        guard textToDisplay != nil else {
            return
        }
        
        textToDisplay = text
        
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 26)
        label.textColor = UIColor(named: "XYTint")
        label.text = text
        label.alpha = 0
        label.sizeToFit()
        self.view.addSubview(label)
        label.center = self.view.center
        
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1.0
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.3, delay: 1.0) {
                    label.alpha = 0.0
                } completion: { (done) in
                    if done {
                        self.textToDisplay = nil
                        label.removeFromSuperview()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == captionTextField {
            if !captionTextFieldDidBeginEditing {
                textView.text = ""
                captionTextFieldDidBeginEditing = true
            }
        } else if textView == challengeTitleTextField {
            if textView.text == "" {
                challengeTitleLabel?.alpha = 1.0
                challengeTitleLabel?.label.text = "#"
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == challengeTitleTextField else {
            return
        }
        let trimmedText = String(textView.text.prefix(15))
        
        challengeTitleLabel?.label.text = "#\(trimmedText)"
        textView.text = trimmedText
        maxCharsLabel.text = "\(trimmedText.count)/15"
        
        layoutInputFieldsForNewChallenge()
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func tappedToEditChallengeName() {
        challengeTitleTextField.becomeFirstResponder()
    }
    
    @objc private func didTapNextButton() {
        if challengeViewModel == nil {
            // New Challenge
            guard let gradientLabel = challengeTitleLabel?.label, gradientLabel.text != "", captionTextField.text != "" else {
                return
            }
        } else {
            // Existing Challenge
            
        }
        
        nextButton.isEnabled = false
        
        let activityIndicator = UIActivityIndicatorView()
        view.addSubview(activityIndicator)
        activityIndicator.frame = CGRect(
            x: view.center.x - 18,
            y: 75,
            width: 36,
            height: 36
        )
        activityIndicator.startAnimating()
        
        if let recordedVideoUrl = recordedVideoUrl {
            previewLayer?.player?.pause()
            
            if challengeViewModel == nil {
                guard
                    var challengeTitle = challengeTitleLabel?.label.text,
                    let description = captionTextField.text,
                    let userID = AuthManager.shared.userId
                else {
                    return
                }
                
                self.displayTemporaryLabel(text: "Creating Challenge...")
                challengeTitle.removeFirst()
                
                // Create new challenge
                ChallengesFirestoreManager.shared.createChallenge(
                    title: challengeTitle,
                    description: description,
                    category: .playerChallenges) { challengeID in
                    
                    let challengeModel = ChallengeModel(
                        id: challengeID,
                        title: challengeTitle,
                        description: description,
                        creatorID: userID,
                        category: .playerChallenges,
                        level: 0,
                        xp: 0
                    )
                    
                    self.displayTemporaryLabel(text: "Uploading video...")
                    
                    // Upload video to challenge
                    ChallengesFirestoreManager.shared.uploadChallengeVideo(
                        videoUrl: recordedVideoUrl,
                        challengeID: challengeID, caption: nil) { (ID, videoID) in
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    }
            } else {
                // Upload to existing challenge
                guard
                    let challengeViewModel = self.challengeViewModel,
                    let caption = captionTextField.text,
                    let userID = AuthManager.shared.userId
                else {
                    return
                }
                
                self.displayTemporaryLabel(text: "Uploading video...")
                
                // Upload video to challenge
                ChallengesFirestoreManager.shared.uploadChallengeVideo(
                    videoUrl: recordedVideoUrl,
                    challengeID: challengeViewModel.id,
                    caption: caption
                ) { (ID, videoID) in
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func didTapClosePreview() {
        previewLayer?.player?.pause()
        previewLayer?.removeFromSuperlayer()
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func didTapCaptionView() {
        caption.toggleInputMode(inputMode: true)
        view.setNeedsLayout()
        
    }
    
    @objc private func didTapAnywhere() {
        if caption.isEditing() {
            caption.toggleInputMode(inputMode: false)
            
            view.setNeedsLayout()
        } else {
            if let player = previewLayer?.player {
                if player.timeControlStatus == .playing {
                    player.pause()
                } else if player.timeControlStatus == .paused {
                    player.play()
                }
            }
        }
    }
    
    @objc private func didTapVideo() {
        if let player = previewLayer?.player {
            player.volume = player.volume == 0.0 ? 1.0 : 0.0
        }
    }
}
