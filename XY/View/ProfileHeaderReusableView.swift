//
//  ProfileHeaderReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import UIKit

class ProfileHeaderReusableView: UICollectionReusableView {
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        
        image.image = UIImage(named: "J2NTP9Er4Ad3kRsms7XRoD")
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
        
        imageView.image = UIImage(named: "elizabeth_online")
        
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        label.textColor = .white
        label.text = "Bro Man"
        return label
    }()
    
    private let xynameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = .white
        label.text = "@xyname"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = .white
        label.text = "This is the description of my profile"
        return label
    }()
    
    private let websiteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 10)
        label.textColor = .white
        label.text = "www.aaaaaa.com"
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
        
        backgroundColor = .purple
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        addSubview(coverImage)
        addSubview(profileCard)
        addSubview(profilePicture)
        
        profileCard.layer.addSublayer(gradientLayer)
        
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
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: 10.9,
            y: 25.59,
            width: nicknameLabel.width,
            height: nicknameLabel.height
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
}
