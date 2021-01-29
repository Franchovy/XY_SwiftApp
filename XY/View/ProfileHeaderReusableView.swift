//
//  ProfileHeaderReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import UIKit
import FirebaseAuth

class ProfileHeaderReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileHeaderReusableView"
    
    var viewModel: ProfileViewModel?
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .black
        return image
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.4, y: 0)
        gradientLayer.colors = [
            UIColor(0x141516).withAlphaComponent(0.8).cgColor,
            UIColor(0x1C1D1E).withAlphaComponent(0.6).cgColor,
            UIColor(0x2F2F2F).withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.locations = [0.0, 0.7, 1.0]
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
        textField.isHidden = true
        return textField
    }()
    
    private lazy var editCoverImageButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "cameraEditButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private lazy var editProfileImageButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "cameraEditButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private var editable = true
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        addSubview(coverImage)
        addSubview(profileCard)
        addSubview(profilePicture)
        
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
            
            addSubview(editProfileImageButton)
            addSubview(editCoverImageButton)
            
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
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        coverImage.frame = bounds
        
        profileCard.frame = CGRect(
            x: 0,
            y: height - 136,
            width: width,
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
            let editButtonIconSize:CGFloat = 11
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
            
            let editPicIconSize: CGFloat = 25
            editProfileImageButton.frame = CGRect(
                x: profilePicture.left + 10,
                y: profilePicture.top + 10,
                width: editPicIconSize,
                height: editPicIconSize
            )
            editProfileImageButton.frame = CGRect(
                x: coverImage.left + 10,
                y: coverImage.top + 10,
                width: editPicIconSize,
                height: editPicIconSize
            )
        }
    }
    
    @objc private func onEnterEditMode() {
        editNicknameTextField.text = nicknameLabel.text
        nicknameLabel.isHidden = true
        editNicknameTextField.isHidden = false
        
        editCaptionTextField.text = descriptionLabel.text
        editCaptionTextField.isHidden = false
        descriptionLabel.isHidden = true
        
        editWebsiteTextField.text = websiteLabel.text
        editWebsiteTextField.isHidden = false
        websiteLabel.isHidden = true
        
        setNeedsLayout()
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
    }
    
    @objc private func onTextFieldChanged(_ sender: UITextField) {
        setNeedsLayout()
    }
    
    @objc private func onTextFieldEnded(_ sender: UITextField) {
        
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
        
        setNeedsLayout()
        
        guard let nickname = nicknameLabel.text, let descriptionText = descriptionLabel.text, let website = websiteLabel.text else {
            return
        }
        
        viewModel?.profileData.nickname = nickname
        viewModel?.profileData.caption = descriptionText
        viewModel?.profileData.website = website
        
        // Send update to backend
        viewModel?.sendEditUpdate()
    }
    
    public func getScrollPosition() -> CGFloat {
        return profilePicture.top + 10
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        if viewModel.userId == Auth.auth().currentUser?.uid {
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

        setNeedsLayout()
        
        guard let level = viewModel.level, let xp = viewModel.xp, let nextLevelXp = XPModel.LEVELS[.user]?[level] else {
            return
        }
        xpCircle.setProgress(level: level, progress: Float(xp) / Float(nextLevelXp))
    }
}

// MARK: - ProfileViewModel delegate functions

extension ProfileHeaderReusableView: ProfileViewModelDelegate {
    func setCoverPictureOpacity(_ opacity: CGFloat) {
        coverImage.alpha = opacity
    }
    
    func onXpUpdate(_ model: XPModel) {
        guard let nextLevelXp = XPModel.LEVELS[.user]?[model.level] else {
            return
        }
        
        self.xpCircle.setProgress(level: model.level, progress: Float(model.xp) / Float(nextLevelXp))
    }
    
    func onXYNameFetched(_ xyname: String) {
        xynameLabel.text = xyname
                
        setNeedsLayout()
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
