//
//  EditProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let nicknameTextField: TextFieldCard = {
        let textField = TextFieldCard()
        textField.textColor = UIColor(named: "XYTint")
        textField.font = UIFont(name: "Raleway-Heavy", size: 25)
        textField.backgroundColor = UIColor(named: "XYCard")
        textField.textAlignment = .center
        return textField
    }()
    
    private let captionTextView: TextViewCard = {
        let textView = TextViewCard()
        textView.setPlaceholderText(text: "Write a caption for your profile")
        textView.setMaxChars(maxChars: 100)
        return textView
    }()
    
    private var prompt: ButtonChoicePrompt?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(profileImage)
        view.addSubview(nicknameTextField)
        view.addSubview(captionTextView)
        
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage)))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere)))
        
        nicknameTextField.onFinishedEditing = { nickname in
            self.updateNickname(with: nickname)
        }
        
        captionTextView.onFinishedEditing = { caption in
            self.updateCaption(with: caption)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit Profile"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let profileImageSize:CGFloat = 110
        profileImage.frame = CGRect(
            x: (view.width - profileImageSize)/2,
            y: 20,
            width: profileImageSize,
            height: profileImageSize
        )
        profileImage.layer.cornerRadius = profileImageSize/2
        
        nicknameTextField.sizeToFit()
        nicknameTextField.frame = CGRect(
            x: (view.width - nicknameTextField.width)/2,
            y: profileImage.bottom + 15,
            width: nicknameTextField.width,
            height: nicknameTextField.height
        )
        
        captionTextView.frame = CGRect(
            x: 21,
            y: nicknameTextField.bottom + 23,
            width: view.width - 42,
            height: 74
        )
    }
    
    public func configure() {
        guard let profileModel = ProfileManager.shared.ownProfile else {
            return
        }
        ProfileViewModelBuilder.build(
            with: profileModel,
            fetchingProfileImage: true,
            fetchingCoverImage: false) { (profileViewModel) in
            if let profileViewModel = profileViewModel {
                self.captionTextView.setText(profileViewModel.caption)
                self.nicknameTextField.setText(profileViewModel.nickname)
                self.profileImage.image = profileViewModel.profileImage
            }
        }
    }
    
    private func updateNickname(with nickname: String) {
        ProfileFirestoreManager.shared.setProfileNickname(nickname)
    }
    
    private func updateCaption(with caption: String) {
        ProfileFirestoreManager.shared.setProfileCaption(caption)
    }
    
    @objc private func didTapProfileImage() {
        
        let prompt = ButtonChoicePrompt()
        
        prompt.addButton(
            buttonText: "Take photo",
            buttonIcon: UIImage(systemName: "camera.fill")) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        prompt.addButton(
            buttonText: "Choose from library",
            buttonIcon: UIImage(systemName: "photo.on.rectangle.angled")) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        view.addSubview(prompt)
        prompt.alpha = 0.0
        prompt.sizeToFit()
        prompt.center = view.center
        prompt.frame.origin.y -= 100
        
        prompt.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        UIView.animate(withDuration: 0.3) {
            prompt.alpha = 1.0
            prompt.transform = .identity
        }
    }
    
    @objc private func didTapAnywhere() {
        nicknameTextField.resignFirstResponder()
        captionTextView.resignFirstResponder()
    }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            self.prompt?.close()
        })
        
        if let image = info[.editedImage] as? UIImage {
            ProfileFirestoreManager.shared.setProfileImage(image: image)
            profileImage.image = image
        } else if let image = info[.originalImage] as? UIImage {
            ProfileFirestoreManager.shared.setProfileImage(image: image)
            profileImage.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.prompt?.close()
        })
    }
}
