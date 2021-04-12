//
//  EditProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let profileImage = EditProfileImageView()
    private let nicknameTextField = EditNicknameTextField()
    
    private let friendsLabelView = LabelView()
    private let challengeLabelView = LabelView()
    
    private var imagePickerController: UIImagePickerController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(profileImage)
        view.addSubview(nicknameTextField)
        view.addSubview(friendsLabelView)
        view.addSubview(challengeLabelView)
        
        configure()
        
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage)))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere)))
        
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .done, target: self, action: #selector(didTapSettings))
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
        
        nicknameTextField.sizeToFit()
        nicknameTextField.frame = CGRect(
            x: (view.width - nicknameTextField.width)/2,
            y: profileImage.bottom + 15,
            width: nicknameTextField.width,
            height: nicknameTextField.height
        )
        
        
        friendsLabelView.sizeToFit()
        friendsLabelView.frame = CGRect(
            x: profileImage.left + 5 - friendsLabelView.width/2,
            y: nicknameTextField.bottom + 10,
            width: friendsLabelView.width,
            height: friendsLabelView.height
        )
        
        challengeLabelView.sizeToFit()
        challengeLabelView.frame = CGRect(
            x: profileImage.right - 5 - challengeLabelView.width/2,
            y: nicknameTextField.bottom + 10,
            width: challengeLabelView.width,
            height: challengeLabelView.height
        )
    }
    
    private func configure() {
        let viewModel = ProfileDataManager.ownViewModel
        
        nicknameTextField.text = viewModel.nickname
        nicknameTextField.sizeToFit()
        
        friendsLabelView.addLabel(String(describing: viewModel.numFriends), font: UIFont(name: "Raleway-Medium", size: 25)!)
        friendsLabelView.addLabel("Friends", font: UIFont(name: "Raleway-Medium", size: 15)!)
        friendsLabelView.addOnPress {
            let prompt = Prompt()
            prompt.setTitle(text: "Friends")
            let numFriendsText = "\(viewModel.numFriends) friend\(viewModel.numFriends != 1 ? "s" : "")"
            prompt.addTextWithBoldInRange(
                text: "You have \(numFriendsText) to challenge.",
                range: NSRange(
                    location: 9,
                    length: numFriendsText.count
                )
            )
            prompt.addCompletionButton(buttonText: "Ok", style: .embedded, closeOnTap: true)
            
            NavigationControlManager.displayPrompt(prompt)
        }
        
        challengeLabelView.addLabel(String(describing: viewModel.numChallenges), font: UIFont(name: "Raleway-Medium", size: 25)!)
        challengeLabelView.addLabel("Challenges", font: UIFont(name: "Raleway-Medium", size: 15)!)
        challengeLabelView.addOnPress {
            let prompt = Prompt()
            prompt.setTitle(text: "Challenges")
            let numFriendsText = "\(viewModel.numChallenges) challenge\(viewModel.numChallenges != 1 ? "s" : "")"
            prompt.addTextWithBoldInRange(
                text: "You have completed \(numFriendsText).",
                range: NSRange(
                    location: 19,
                    length: numFriendsText.count
                )
            )
            prompt.addCompletionButton(buttonText: "Ok", style: .embedded, closeOnTap: true)
            
            NavigationControlManager.displayPrompt(prompt)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePickerController?.dismiss(animated: true, completion: nil)
        imagePickerController = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController?.dismiss(animated: true, completion: nil)
        imagePickerController = nil
    }
    
    @objc private func didTapProfileImage() {
        let prompt = Prompt()
        prompt.setTitle(text: "Change Profile Photo")
        prompt.addButtonField(
            image: UIImage(systemName: "camera.fill"),
            buttonText: "Take Photo",
            font: UIFont(name: "Raleway-Medium", size: 15),
            onTap: didTapCamera)
        prompt.addButtonField(
            image: UIImage(systemName: "photo.fill.on.rectangle.fill"),
            buttonText: "Photo Library",
            font: UIFont(name: "Raleway-Medium", size: 15),
            onTap: didTapPhotoLibrary)
        prompt.addCompletionButton(buttonText: "Cancel", style: .embedded, closeOnTap: true)
        
        NavigationControlManager.displayPrompt(prompt)
    }
    
    @objc private func didTapCamera() {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = .camera
        imagePickerController!.allowsEditing = true
        imagePickerController!.delegate = self
        present(imagePickerController!, animated: true)
    }
    
    @objc private func didTapPhotoLibrary() {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = .photoLibrary
        imagePickerController!.allowsEditing = true
        imagePickerController!.delegate = self
        present(imagePickerController!, animated: true)
    }
    
    @objc private func didTapSettings() {
        NavigationControlManager.mainViewController.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    @objc private func tappedAnywhere() {
        if let text = nicknameTextField.text, text != "" {
            ProfileDataManager.ownViewModel.nickname = text
        } else {
            nicknameTextField.text = ProfileDataManager.ownViewModel.nickname
        }
        
        nicknameTextField.resignFirstResponder()
    }
}
