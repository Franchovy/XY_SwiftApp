//
//  DescriptionViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit


class DescriptionViewController: UIViewController, UITextViewDelegate {
    
    private let challengeNameTextField = TextField(placeholder: "Give a title to your challenge...", style: .card, maxChars: 15)
    private let challengeDescriptionTextField = TextField(placeholder: "Describe what you have to do in your challenge...", style: .card, maxChars: 50)
    
    private let challengePreviewImage = UIImageView()
    private let previewLabel = Label("Preview", style: .info, fontSize: 15, adaptToLightMode: false)
    
    private let downloadVideoButton = Button(image: UIImage(systemName: "arrow.down.to.line"), title: "Save video", style: .card, titlePosition: .belowImage, imageSizeIncrease: 30)

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.visible)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere)))
        
        challengeNameTextField.delegate = self
        challengeDescriptionTextField.delegate = self
        
        view.addSubview(challengeNameTextField)
        view.addSubview(challengeDescriptionTextField)
        view.addSubview(challengePreviewImage)
        view.addSubview(downloadVideoButton)
        view.addSubview(previewLabel)
        
        challengePreviewImage.isUserInteractionEnabled = true
        challengePreviewImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewImagePressed)))
        
        challengePreviewImage.alpha = 0.7
        challengePreviewImage.layer.cornerRadius = 5
        
        navigationItem.title = "Description"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapNext))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        downloadVideoButton.addTarget(self, action: #selector(didTapSaveVideo), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeNameTextField.frame = CGRect(
            x: 11,
            y: 15,
            width: 250,
            height: 81
        )
        
        challengeDescriptionTextField.frame = CGRect(
            x: 11,
            y: challengeNameTextField.bottom + 9,
            width: 250,
            height: 198
        )
        
        challengePreviewImage.frame = CGRect(
            x: challengeNameTextField.right + 10,
            y: 15,
            width: 94,
            height: 130
        )
        
        previewLabel.sizeToFit()
        previewLabel.center = challengePreviewImage.center
        
        let downloadVideoButtonSize = CGSize(width: 105, height: 74)
        downloadVideoButton.frame = CGRect(
            x: (view.width - downloadVideoButtonSize.width)/2,
            y: view.height - downloadVideoButtonSize.height - 30,
            width: downloadVideoButtonSize.width,
            height: downloadVideoButtonSize.height
        )
    }
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = challengeNameTextField.text != "" && challengeDescriptionTextField.text != ""
    }
    
    func loadFromManager() {
        challengeNameTextField.setText(CreateChallengeManager.shared.title!)
        challengeDescriptionTextField.setText(CreateChallengeManager.shared.description!)
        challengePreviewImage.image = CreateChallengeManager.shared.previewImage
    }
    
    @objc private func didTapNext() {
        CreateChallengeManager.shared.description = challengeDescriptionTextField.text
        CreateChallengeManager.shared.title = challengeNameTextField.text
        
        guard let cardViewModel = CreateChallengeManager.shared.getChallengeCardViewModel() else {
            return
        }
        let vc = SendChallengeViewController(with: cardViewModel)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func previewImagePressed() {
        CreateChallengeManager.shared.changePreviewImageTimestamp()
        
        challengePreviewImage.image = CreateChallengeManager.shared.previewImage
    }
    
    @objc private func didTapSaveVideo() {
        guard let url = CreateChallengeManager.shared.videoUrl else {
            return
        }
        VideoSaver.saveVideoWithUrl(url: url) { success, error in
            DispatchQueue.main.async {
                if success {
                    let prompt = Prompt()
                    prompt.setTitle(text: "Success")
                    prompt.addText(text: "Video saved to your photos library.")
                    
                    NavigationControlManager.displayPrompt(prompt)
                } else {
                    let prompt = Prompt()
                    prompt.setTitle(text: "Error")
                    prompt.addText(text: "Video failed to save to your library.")
                    if let error = error {
                        prompt.addText(text: error.localizedDescription, font: UIFont(name: "Raleway-Bold", size: 12)!)
                    }
                    NavigationControlManager.displayPrompt(prompt)
                }
            }
        }
    }
    
    @objc private func tappedAnywhere() {
        challengeDescriptionTextField.resignFirstResponder()
        challengeNameTextField.resignFirstResponder()
    }
}
