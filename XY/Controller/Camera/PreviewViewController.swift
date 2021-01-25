//
//  PreviewViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/01/2021.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController {
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = UIColor(named: "tintColor")
        return button
    }()
    
    private let closePreviewButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: "tintColor")
        return button
    }()
    
    private let caption: MessageView
    
    private var playerDidFinishObserver: NSObjectProtocol?
    private var previewLayerView = UIView()
    private var previewLayer: AVPlayerLayer?
    
    private var recordedVideoUrl: URL?
    private var previewImageView: UIImageView?
    
    //MARK: - Init
    
    init(previewVideoUrl: URL) {
        caption = MessageView()
        caption.text = "Write your caption..."
        caption.isEditable = true
        
        super.init(nibName: nil, bundle: nil)
        
        let player = AVPlayer(url: previewVideoUrl)
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
        
        recordedVideoUrl = previewVideoUrl
    }
    
    init(previewImage: UIImage) {
        caption = MessageView()
        caption.text = "Write your caption..."
        caption.setColor(.blue)
        caption.isEditable = true
        
        super.init(nibName: nil, bundle: nil)
        
        self.previewImageView = UIImageView(image: previewImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(previewLayerView)
        view.addSubview(nextButton)
        view.addSubview(closePreviewButton)
        
        view.addSubview(caption)
        
        if let previewImageView = previewImageView {
            view.addSubview(previewImageView)
        }
    
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        closePreviewButton.addTarget(self, action: #selector(didTapClosePreview), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCaptionView))
        caption.addGestureRecognizer(tapGestureRecognizer)
        
        let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere))
        view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
    }
    
    @objc private func didTapCaptionView() {
        caption.toggleInputMode(inputMode: true)
    }
    
    @objc private func didTapAnywhere() {
        let captionText = caption.text
        print("Caption: \(captionText)")
        caption.toggleInputMode(inputMode: false)
        
        view.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutPreviewButtons()
        
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
            
            captionY = previewImageView.bottom + 10
        }
        
        
        caption.frame = CGRect(
            x: 10,
            y: captionY,
            width: caption.width,
            height: caption.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let previewLayer = previewLayer {
            previewLayer.player?.play()
        }
    }
    
    func layoutPreviewButtons() {
        let size: CGFloat = 25
        
        nextButton.frame = CGRect(
            x: view.right - 25 - size,
            y: view.top + 25 + view.safeAreaInsets.top,
            width: size,
            height: size
        )
                
        closePreviewButton.frame = CGRect(
            x: 25,
            y: view.top + 25 + view.safeAreaInsets.top,
            width: size,
            height: size
        )
    }
    
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
            FirebaseUpload.createPost(caption: caption.text, image: image) { (result) in
                activityIndicator.stopAnimating()
                
                switch result {
                case .success(let postModel):
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error creating post.")
                }
            }
        } else
        
        if let recordedVideoUrl = recordedVideoUrl {
            // Upload video
            FirebaseUpload.uploadVideo(with: recordedVideoUrl) { [weak self] (result) in
                activityIndicator.stopAnimating()
                
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
                    self?.dismiss(animated: true, completion: nil)
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc private func didTapClosePreview() {
        dismiss(animated: true, completion: nil)
    }
}
