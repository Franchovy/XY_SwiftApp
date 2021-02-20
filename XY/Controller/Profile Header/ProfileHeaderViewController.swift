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
    var viewModel: ProfileViewModel?
    
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
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.4, y: 0)
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
    
    private let profilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        imageView.layer.addSublayer(shadowLayer)
        // Probably needs to mask differently to work
        
        return imageView
    }()
    
    private let xpCircle: CircleView = {
        let xpCircle = CircleView()
        return xpCircle
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        label.textColor = .white
        
        return label
    }()
    
    private let xynameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = .white
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = .white
        
        return label
    }()
    
    private let websiteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = .white
        
        return label
    }()
    
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
    
    private lazy var editNicknameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        textField.textColor = .white
        textField.isHidden = true
        return textField
    }()
    
    private lazy var editCaptionTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.font = UIFont(name: "HelveticaNeue", size: 15)
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
        textField.font = UIFont(name: "HelveticaNeue", size: 13)
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
        view.addSubview(profilePicture)
        
        profileCard.layer.addSublayer(gradientLayer)
        
        profileCard.addSubview(xpCircle)
        profileCard.addSubview(xynameLabel)
        profileCard.addSubview(websiteLabel)
        profileCard.addSubview(websiteIcon)
        profileCard.addSubview(nicknameLabel)
        profileCard.addSubview(descriptionLabel)
        
        if editable {
            profileCard.addSubview(editButton)
            
            profileCard.addSubview(editNicknameTextField)
            profileCard.addSubview(editWebsiteTextField)
            profileCard.addSubview(editCaptionTextField)
            
            view.addSubview(editCoverImageButton)
            editCoverImageButton.addTarget(self, action: #selector(editCoverImage), for: .touchUpInside)
            
            let tapProfilePictureGesture = UITapGestureRecognizer(target: self, action: #selector(editProfilePicture))
            profilePicture.addGestureRecognizer(tapProfilePictureGesture)
            
            editButton.addTarget(self, action: #selector(onEnterEditMode), for: .touchUpInside)
            
            editNicknameTextField.addTarget(self, action: #selector(onTextFieldTapped(_:)), for: .editingDidBegin)
            editWebsiteTextField.addTarget(self, action: #selector(onTextFieldTapped(_:)), for: .editingDidBegin)
            editCaptionTextField.addTarget(self, action: #selector(onTextFieldTapped(_:)), for: .editingDidBegin)
            
            editNicknameTextField.addTarget(self, action: #selector(onTextFieldChanged(_:)), for: .editingChanged)
            editWebsiteTextField.addTarget(self, action: #selector(onTextFieldChanged(_:)), for: .editingChanged)
            editCaptionTextField.addTarget(self, action: #selector(onTextFieldChanged(_:)), for: .editingChanged)
            
            editNicknameTextField.addTarget(self, action: #selector(onTextFieldEnded(_:)), for: .editingDidEnd)
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
        
        coverImage.frame = view.bounds.inset(by: UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: 67, right: 0))
        
        profileCard.frame = CGRect(
            x: 0,
            y: view.height - 136 - 67,
            width: view.width,
            height: 136
        )
        
        gradientLayer.frame = profileCard.bounds
        
        let profilePictureSize:CGFloat = 60
        profilePicture.frame = CGRect(
            x: 11,
            y: profileCard.top - profilePictureSize/2,
            width: profilePictureSize,
            height: profilePictureSize
        )
        profilePicture.layer.cornerRadius = profilePictureSize/2
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: 10.9,
            y: 27.59,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        xpCircle.frame = CGRect(
            x: nicknameLabel.right + 9,
            y: nicknameLabel.bottom - 25,
            width: 25,
            height: 25
        )
        
        xynameLabel.sizeToFit()
        xynameLabel.frame = CGRect(
            x: 11,
            y: nicknameLabel.bottom + 5,
            width: xynameLabel.width,
            height: xynameLabel.height
        )
        descriptionLabel.sizeToFit()
        descriptionLabel.frame = CGRect(
            x: 11,
            y: xynameLabel.bottom + 5,
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
            
            editNicknameTextField.sizeToFit()
            editNicknameTextField.frame = CGRect(
                x: nicknameLabel.left,
                y: nicknameLabel.top,
                width: editNicknameTextField.width,
                height: editNicknameTextField.height
            )
            xpCircle.frame.origin.x = max(nicknameLabel.right, editNicknameTextField.right) + 9
            
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
        
        editNicknameTextField.text = nicknameLabel.text
        nicknameLabel.isHidden = true
        editNicknameTextField.isHidden = false
        
        editCaptionTextField.text = descriptionLabel.text
        editCaptionTextField.isHidden = false
        descriptionLabel.isHidden = true
        
        editWebsiteTextField.text = websiteLabel.text
        editWebsiteTextField.isHidden = false
        websiteLabel.isHidden = true
        
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 2
        
        profilePicture.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.1) {
            self.editCoverImageButton.alpha = 1.0
        }
        
        delegate?.didEnterEditMode()
        
        view.setNeedsLayout()
    }
        
    @objc private func onTextFieldTapped(_ sender: UITextField) {
        switch sender {
        case editNicknameTextField:
            editNicknameTextField.becomeFirstResponder()
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
        
        editNicknameTextField.isHidden = true
        nicknameLabel.isHidden = false
        if editNicknameTextField.text != "" {
            nicknameLabel.text = editNicknameTextField.text
        }
    
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
        
        profilePicture.layer.borderColor = UIColor.clear.cgColor
        profilePicture.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.1) {
            self.editCoverImageButton.alpha = 0.0
        }
        
        view.setNeedsLayout()
        
        guard let nickname = nicknameLabel.text, let descriptionText = descriptionLabel.text, let website = websiteLabel.text else {
            return
        }
        
        viewModel?.profileData.nickname = nickname
        viewModel?.profileData.caption = descriptionText
        viewModel?.profileData.website = website
        
        delegate?.didExitEditMode()
        // Send update to backend
        viewModel?.sendEditUpdate()
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
            editNicknameTextField,
            editCaptionTextField,
            editWebsiteTextField
        ] {
            view?.resignFirstResponder()
        }
    }
    
    public func getScrollPosition() -> CGFloat {
        return profilePicture.top + 10
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        guard let userId = AuthManager.shared.userId else { return }
        
        if viewModel.userId == userId {
            editButton.isHidden = false
        }
        
        nicknameLabel.text = viewModel.nickname
        descriptionLabel.text = viewModel.caption
        if let xyname = viewModel.xyname {
            xynameLabel.text = viewModel.xyname
        }
        websiteLabel.text = viewModel.website
        
        profilePicture.image = viewModel.profileImage
        coverImage.image = viewModel.coverImage

        view.setNeedsLayout()
        
        guard let level = viewModel.level, let xp = viewModel.xp else {
            return
        }
        let nextLevelXp = XPModelManager.shared.getXpForNextLevelOfType(level, .user)
        
        xpCircle.setProgress(level: level, progress: Float(xp) / Float(nextLevelXp))
        xpCircle.layoutSubviews()
    }
    
    
    public func configure(with viewModel: NewProfileViewModel) {
//        self.viewModel = viewModel
        
        guard let userId = AuthManager.shared.userId else { return }
        
        if viewModel.userId == userId {
            editButton.isHidden = false
        }
        
        nicknameLabel.text = viewModel.nickname
        descriptionLabel.text = viewModel.caption
        xynameLabel.text = "@\(viewModel.xyname)"
        websiteLabel.text = viewModel.website
        
        profilePicture.image = viewModel.profileImage
        coverImage.image = viewModel.coverImage

        view.setNeedsLayout()
        
        let nextLevelXp = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user)
        
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXp))
        xpCircle.layoutSubviews()
    }
}

// MARK: - ProfileViewModel delegate functions

extension ProfileHeaderViewController: ProfileViewModelDelegate {
    func setCoverPictureOpacity(_ opacity: CGFloat) {
        coverImage.alpha = opacity
    }
    
    func onXpUpdate(_ model: XPModel) {
        let nextLevelXp = XPModelManager.shared.getXpForNextLevelOfType(model.level, .user)
        
        self.xpCircle.setProgress(level: model.level, progress: Float(model.xp) / Float(nextLevelXp))
    }
    
    func onXYNameFetched(_ xyname: String) {
        xynameLabel.text = xyname
                
        view.setNeedsLayout()
    }
    
    func onProfileDataFetched(_ viewModel: ProfileViewModel) {
        configure(with: viewModel)
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        profilePicture.image = image
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
                    viewModel.profileData.coverImageId = imageId
                    viewModel.sendEditUpdate()
                }
            }
            break
        case .profilePicture:
            // Update profile picture
            profilePicture.image = image
            exitEditMode()
            
            FirebaseUpload.uploadImage(image: image!) { (imageId, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: "Could not upload your profile picture!", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    print(error)
                    return
                } else if let imageId = imageId, let viewModel = self.viewModel {
                    viewModel.profileData.profileImageId = imageId
                    viewModel.sendEditUpdate()
                }
            }
        }
    }
}
