//
//  ProfileHeaderViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit

protocol ProfileHeaderViewControllerDelegate: AnyObject {
    func didEnterEditMode()
    func didExitEditMode()
}

class ProfileHeaderViewController: UIViewController {
    
    var delegate: ProfileHeaderViewControllerDelegate?
    var viewModel: NewProfileViewModel?
    
    var imagePicker: UIImagePickerController?
    
    enum ImageToPickType {
        case profilePicture
        case coverPicture
    }
    var imagePickerImageToPick: ImageToPickType?
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 15

        image.layer.masksToBounds = true
        return image
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.9)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.0)
        gradientLayer.colors = [
            UIColor(0x141516).withAlphaComponent(0.8).cgColor,
            UIColor(0x1C1D1E).withAlphaComponent(0.6).cgColor,
            UIColor(0x2F2F2F).withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 1.0]
        gradientLayer.type = .axial
        return gradientLayer
    }()
    
    private let profileCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    private let profileBubble = ProfileBubble()
    
    private let xynameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.textColor = .white
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowRadius = 6
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.86
        return label
    }()
    
    private let numFollowers = XYLabel(fontSize: 20, fontStyle: .bold, tintStyle: .white, shadowEnabled: true)
    private let numFollowing = XYLabel(fontSize: 20, fontStyle: .bold, tintStyle: .white, shadowEnabled: true)
    private let numSwipeRights = XYLabel(fontSize: 20, fontStyle: .bold, tintStyle: .white, shadowEnabled: true)
    private let numFollowersLabel = XYLabel(text: "Followers", fontSize: 12, fontStyle: .medium, tintStyle: .white, shadowEnabled: true)
    private let numFollowingLabel = XYLabel(text: "Following", fontSize: 12, fontStyle: .medium, tintStyle: .white, shadowEnabled: true)
    private let numSwipeRightsLabel = XYLabel(text: "Swipe Rights", fontSize: 12, fontStyle: .medium, tintStyle: .white, shadowEnabled: true)
    
    private let descriptionLabel = XYLabel(fontSize: 14, fontStyle: .medium, tintStyle: .white, shadowEnabled: true)
    private let websiteLabel = XYLabel(fontSize: 13, fontStyle: .medium, tintStyle: .white, shadowEnabled: true)
    
    private let websiteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "linkIcon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "edit")?.withTintColor(.white), for: .normal)
        button.contentMode = .scaleAspectFill
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        return button
    }()
    
    // MARK: - Edit Profile properties
    
    private lazy var editCaptionTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.font = UIFont(name: "Raleway-Medium", size: 15)
        textField.textColor = .white
        textField.isHidden = true
        return textField
    }()
    
    private lazy var editWebsiteTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.font = UIFont(name: "Raleway-Medium", size: 13)
        textField.textColor = .white
        textField.isHidden = true
        return textField
    }()
    
    private lazy var editCoverImageButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.0
        return button
    }()
    
    private var editable = true
    private var editMode = false
    
    // MARK: - Initializers
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        view.addSubview(coverImage)
        view.addSubview(profileCard)
        view.addSubview(profileBubble)
        profileBubble.delegate = self
        
        profileCard.layer.addSublayer(gradientLayer)
        
        profileCard.addSubview(numFollowers)
        profileCard.addSubview(numFollowing)
        profileCard.addSubview(numSwipeRights)
        profileCard.addSubview(numFollowersLabel)
        profileCard.addSubview(numFollowingLabel)
        profileCard.addSubview(numSwipeRightsLabel)
        
        profileCard.addSubview(xynameLabel)
        profileCard.addSubview(websiteLabel)
        profileCard.addSubview(websiteIcon)
        profileCard.addSubview(descriptionLabel)
        
        if editable {
            profileCard.addSubview(editButton)
            
            profileCard.addSubview(editWebsiteTextField)
            profileCard.addSubview(editCaptionTextField)
            
            view.addSubview(editCoverImageButton)
            editCoverImageButton.addTarget(self, action: #selector(editCoverImage), for: .touchUpInside)
            
//            let tapProfilePictureGesture = UITapGestureRecognizer(target: self, action: #selector(editProfilePicture))
//            profileBubble.addGestureRecognizer(tapProfilePictureGesture)
            
            editButton.addTarget(self, action: #selector(onEnterEditMode), for: .touchUpInside)
            
            editWebsiteTextField.addTarget(self, action: #selector(onTextFieldTapped(_:)), for: .editingDidBegin)
            editCaptionTextField.addTarget(self, action: #selector(onTextFieldTapped(_:)), for: .editingDidBegin)
            
            editWebsiteTextField.addTarget(self, action: #selector(onTextFieldChanged(_:)), for: .editingChanged)
            editCaptionTextField.addTarget(self, action: #selector(onTextFieldChanged(_:)), for: .editingChanged)
            
            editCaptionTextField.addTarget(self, action: #selector(onTextFieldEnded(_:)), for: .editingDidEnd)
            editWebsiteTextField.addTarget(self, action: #selector(onTextFieldEnded(_:)), for: .editingDidEnd)
            
            
            
            let tappedAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere))
            view.addGestureRecognizer(tappedAnywhereGesture)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        coverImage.frame = view.bounds.inset(
            by: UIEdgeInsets(
                top: view.safeAreaInsets.top,
                left: 0,
                bottom: view.safeAreaInsets.bottom,
                right: 0
            )
        )
        
        profileCard.frame = CGRect(
            x: 0,
            y: view.height - 134 - 67,
            width: view.width,
            height: 134
        )
        
        gradientLayer.frame = profileCard.bounds
        
        let profilePictureSize:CGFloat = 60
        profileBubble.frame = CGRect(
            x: 11,
            y: profileCard.top - profilePictureSize,
            width: 200,
            height: 70
        )
        
        xynameLabel.sizeToFit()
        xynameLabel.frame = CGRect(
            x: 10,
            y: 3,
            width: xynameLabel.width,
            height: xynameLabel.height
        )
        
        for index in 0...2 {
            let centerX:CGFloat = [40, 130, 210][index]
            let numLabel = [numFollowers, numFollowing, numSwipeRights][index]
            let label = [numFollowersLabel, numFollowingLabel, numSwipeRightsLabel][index]
            
            numLabel.sizeToFit()
            numLabel.frame = CGRect(
                x: centerX - numLabel.width/2,
                y: xynameLabel.bottom + 6,
                width: numLabel.width,
                height: numLabel.height
            )
            
            label.sizeToFit()
            label.frame = CGRect(
                x: centerX - label.width/2,
                y: numLabel.bottom,
                width: label.width,
                height: label.height
            )
        }
        
        descriptionLabel.sizeToFit()
        descriptionLabel.frame = CGRect(
            x: 11,
            y: numFollowersLabel.bottom + 9,
            width: descriptionLabel.width,
            height: descriptionLabel.height
        )
        let websiteIconSize:CGFloat = 15
        websiteIcon.frame = CGRect(
            x: 10.9,
            y: descriptionLabel.bottom + 7.5,
            width: websiteIconSize,
            height: websiteIconSize
        )
        websiteLabel.sizeToFit()
        websiteLabel.frame = CGRect(
            x: websiteIcon.right + 5.1,
            y: descriptionLabel.bottom + 5,
            width: websiteLabel.width,
            height: websiteLabel.height
        )
        
        if editable {
            let editButtonIconSize:CGFloat = 40
            editButton.frame = CGRect(
                x: profileCard.width - editButtonIconSize - 11,
                y: 6,
                width: editButtonIconSize,
                height: editButtonIconSize
            )
            
            editCaptionTextField.sizeToFit()
            editCaptionTextField.frame = CGRect(
                x: descriptionLabel.left,
                y: descriptionLabel.top,
                width: editCaptionTextField.width,
                height: editCaptionTextField.height
            )
            editWebsiteTextField.sizeToFit()
            editWebsiteTextField.frame = CGRect(
                x: websiteLabel.left,
                y: websiteLabel.top,
                width: editWebsiteTextField.width,
                height: editWebsiteTextField.height
            )
            
            let editPicIconSize: CGFloat = 22

            editCoverImageButton.frame = CGRect(
                x: coverImage.left + 10,
                y: coverImage.top + 50,
                width: editPicIconSize*1.35,
                height: editPicIconSize
            )
        }
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func onEnterEditMode() {
        if editMode {
            exitEditMode()
            return
        }
        
        editMode = true
        
        editCaptionTextField.text = descriptionLabel.text
        editCaptionTextField.isHidden = false
        descriptionLabel.isHidden = true
        
        editWebsiteTextField.text = websiteLabel.text
        editWebsiteTextField.isHidden = false
        websiteLabel.isHidden = true
        
        
        
        UIView.animate(withDuration: 0.1) {
            self.editCoverImageButton.alpha = 1.0
        }
        
        delegate?.didEnterEditMode()
        
        view.setNeedsLayout()
    }
        
    @objc private func onTextFieldTapped(_ sender: UITextField) {
        switch sender {
        case editCaptionTextField:
            editCaptionTextField.becomeFirstResponder()
        case editWebsiteTextField:
            editWebsiteTextField.becomeFirstResponder()
        default:
            fatalError()
        }
        
        sender.returnKeyType = .done
        sender.addTarget(self, action: #selector(onTextFieldEnded(_:)), for: .primaryActionTriggered)
    }
    
    @objc private func onTextFieldChanged(_ sender: UITextField) {
        view.setNeedsLayout()
    }
    
    @objc private func onTextFieldEnded(_ sender: UITextField) {
        exitEditMode()
    }
    
    private func exitEditMode() {
        editMode = false
        
        editCaptionTextField.isHidden = true
        descriptionLabel.isHidden = false
        if descriptionLabel.text != "" {
            descriptionLabel.text = editCaptionTextField.text
        }
        
        editWebsiteTextField.isHidden = true
        websiteLabel.isHidden = false
        if websiteLabel.text != "" {
            websiteLabel.text = editWebsiteTextField.text
        }
        
        UIView.animate(withDuration: 0.1) {
            self.editCoverImageButton.alpha = 0.0
        }
        
        view.setNeedsLayout()
        
        guard let descriptionText = descriptionLabel.text, let website = websiteLabel.text else {
            return
        }
        
//        viewModel?.profileData.caption = descriptionText
//        viewModel?.profileData.website = website
        
        delegate?.didExitEditMode()
        // Send update to backend
//        viewModel?.sendEditUpdate()
    }
    
    @objc private func editProfilePicture() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = true
        imagePickerImageToPick = .profilePicture
        
        presentImagePickerAlert()
    }
    
    @objc private func editCoverImage() {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = false
        imagePickerImageToPick = .coverPicture
        
        presentImagePickerAlert()
    }
    
    private func presentImagePickerAlert() {
        
        let alert = UIAlertController(title: "Choose Image From:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera()
    {
        if let imagePicker = imagePicker {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let alert  = UIAlertController(title: "Warning", message: "No camera access", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func openGallery()
    {
        if let imagePicker = imagePicker {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Public functions
    
    @objc public func didTapAnywhere() {
        for view in [
            view,
            editCaptionTextField,
            editWebsiteTextField
        ] {
            view?.resignFirstResponder()
        }
    }
    
    public func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        
        guard let userId = AuthManager.shared.userId else { return }
        
        if viewModel.userId == userId {
            editButton.isHidden = false
            profileBubble.setButtonMode(mode: .add)
        } else {
            profileBubble.setButtonMode(mode: .follow)
        }
        
        descriptionLabel.text = viewModel.caption
        xynameLabel.text = "@\(viewModel.xyname)"
        websiteLabel.text = viewModel.website
        profileBubble.configure(with: viewModel)
        
        numFollowers.text = String(viewModel.numFollowers)
        numFollowing.text = String(viewModel.numFollowing)
        numSwipeRights.text = String(viewModel.numSwipeRights)

        coverImage.image = viewModel.coverImage

        view.setNeedsLayout()
    }
    
    public func setHeroID(forProfileImage id: String) {
        isHeroEnabled = true
        profileBubble.setHeroID(id: id)
    }
}

extension ProfileHeaderViewController : ProfileBubbleDelegate {
    func plusButtonPressed() {
        editProfilePicture()
    }
}

// MARK: - ProfileViewModel delegate functions

extension ProfileHeaderViewController: ProfileViewModelDelegate {
    func setCoverPictureOpacity(_ opacity: CGFloat) {
        coverImage.alpha = opacity
    }
    
    func onXpUpdate(_ model: XPModel) {
        let nextLevelXp = XPModelManager.shared.getXpForNextLevelOfType(model.level, .user)
        
//        self.xpCircle.setProgress(level: model.level, progress: Float(model.xp) / Float(nextLevelXp))
    }
    
    func onXYNameFetched(_ xyname: String) {
        xynameLabel.text = xyname
                
        view.setNeedsLayout()
    }
    
    func onProfileDataFetched(_ viewModel: ProfileViewModel) {
//        configure(with: viewModel)
    }
    
    func onProfileImageFetched(_ image: UIImage) {
//        profileBubble.configure(with: <#T##ProfileViewModel#>)
    }
    
    func onCoverImageFetched(_ image: UIImage) {
        coverImage.image = image
    }
}


extension ProfileHeaderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker?.dismiss(animated: true)
        
        var image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        guard let imagePickerImageToPick = imagePickerImageToPick, image != nil else {
            return
        }
        
        switch imagePickerImageToPick {
        case .coverPicture:
            // Update cover picture
            coverImage.image = image
            exitEditMode()
            
            FirebaseUpload.uploadImage(image: image!) { (imageId, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: "Could not upload your cover image!", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    print(error)
                    return
                } else if let imageId = imageId, let viewModel = self.viewModel {
//                    viewModel.profileData.coverImageId = imageId
//                    viewModel.sendEditUpdate()
                }
            }
            break
        case .profilePicture:
            // Update profile picture
            exitEditMode()
            
            FirebaseUpload.uploadImage(image: image!) { (imageId, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: "Could not upload your profile picture!", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    print(error)
                    return
                } else if let imageId = imageId, let viewModel = self.viewModel {
//                    viewModel.profileData.profileImageId = imageId
//                    viewModel.sendEditUpdate()
                }
            }
            
            guard var viewModel = viewModel else {
                return
            }
            viewModel.profileImage = image
            profileBubble.configure(with: viewModel)
        }
    }
}
