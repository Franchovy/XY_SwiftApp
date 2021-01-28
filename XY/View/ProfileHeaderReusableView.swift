//
//  ProfileHeaderReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import UIKit

class ProfileHeaderReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileHeaderReusableView"
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
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
        button.setImage(UIImage(named: "edit"), for: .normal)
        button.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
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
        profileCard.addSubview(editButton)
        profileCard.addSubview(descriptionLabel)
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
        let editButtonIconSize:CGFloat = 11
        editButton.frame = CGRect(
            x: profileCard.width - editButtonIconSize - 11,
            y: 6,
            width: editButtonIconSize,
            height: editButtonIconSize
        )
    }
    
    public func configure(with viewModel: ProfileViewModel) {
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

extension ProfileHeaderReusableView: ProfileViewModelDelegate {
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
