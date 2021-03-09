//
//  PreviewViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/01/2021.
//

import UIKit
import AVFoundation

protocol PreviewViewControllerDelegate: AnyObject {
    func didFinishUploadingPost(postData: PostViewModel)
    func didFinishUploadingViral(videoUrl: URL, viralModel: ViralModel)
}

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    private let delegate: PreviewViewControllerDelegate
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "tintColor")
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
        return button
    }()
    
    private let closePreviewButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "tintColor")
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
        return button
    }()
    
    var captionTextFieldDidBeginEditing = false
    private let captionTextField: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "Dark")
        textView.layer.cornerRadius = 5
        textView.font = UIFont(name: "Raleway-Regular", size: 12)
        textView.textColor = UIColor(named: "XYTint")
        textView.text = "Caption your video..."
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
    
    private var playerDidFinishObserver: NSObjectProtocol?
    private var previewLayerView = UIView()
    private var previewLayer: AVPlayerLayer?
    
    private var recordedVideoUrl: URL?
    private var previewImageView: UIImageView?
    
    //MARK: - Init
    
    init(previewVideoUrl: URL, delegate: PreviewViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        let player = AVPlayer(url: previewVideoUrl)
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
    }
    
    init(previewImage: UIImage, delegate: PreviewViewControllerDelegate) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        previewLayerView.layer.cornerRadius = 5
        previewLayerView.layer.masksToBounds = true
        previewImageView = UIImageView(image: previewImage)
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
            
            captionTextField.frame = CGRect(
                x: previewLayerView.right + 18,
                y: nextButton.bottom + 10,
                width: view.width - previewLayerView.right - 33,
                height: 73
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let previewLayer = previewLayer {
            previewLayer.player?.play()
        }
    }
    
    // MARK: - Private functions
    
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
    
    private func postUploadComplete(_ postModel: PostModel) {
        
        print("Post upload complete: \(postModel)")
        guard let previewImage = previewImageView?.image else {
            return
        }
        
        let viewmodel = PostViewModel(fromOffline: postModel, image: previewImage)
        
        delegate.didFinishUploadingPost(postData: viewmodel)
    }
    
    private func viralUploadComplete(_ viralModel: ViralModel) {
        guard let videoUrl = recordedVideoUrl else {
            return
        }
        dismiss(animated: true, completion: nil)
        delegate.didFinishUploadingViral(videoUrl: videoUrl, viralModel: viralModel)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !captionTextFieldDidBeginEditing {
            textView.text = ""
            captionTextFieldDidBeginEditing = true
        }
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func didTapNextButton() {
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
        
        if let image = previewImageView?.image {
            // Upload post
            PostManager.shared.createPost(caption: caption.text, image: image) { (result) in
                activityIndicator.stopAnimating()
                
                switch result {
                case .success(let postModel):
                    
                    self.postUploadComplete(postModel)
                case .failure(let error):
                    print("Error creating post: \(error)")
                }
            }
        } else if let recordedVideoUrl = recordedVideoUrl {
            previewLayer?.player?.pause()
            
            let caption = self.caption.text
            
            // Upload video
            ViralManager.shared.createViral(caption: caption, videoUrl: recordedVideoUrl) { (result) in
                switch result {
                case .success(let viralModel):
                    self.viralUploadComplete(viralModel)
                case .failure(let error):
                    print("Error uploading viral: \(error)")
                }
            }
        }
    }
    
    @objc private func didTapClosePreview() {
        dismiss(animated: true, completion: nil)
        
        previewLayer?.player?.pause()
        previewLayer?.removeFromSuperlayer()
        
        
        dismiss(animated: true, completion: nil)
        view.removeFromSuperview()
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
}
