//
//  SubscriberCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 20/03/2021.
//

import UIKit

class SubscriberCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SubscriberCollectionViewCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 20)
        label.textColor = UIColor(named: "tintColor")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let xpCircle = CircleView()
    
    private let subscribeButton = FollowButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xpCircle.setLevelLabelFontSize(size: 6)
                
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(xpCircle)
        contentView.addSubview(subscribeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize:CGFloat = 30
        profileImageView.frame = CGRect(
            x: 70,
            y: (height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profileImageView.layer.cornerRadius = imageSize/2
        
        let xpCircleSize: CGFloat = 20
        xpCircle.frame = CGRect(
            x: width - xpCircleSize - 33.58,
            y: (height - xpCircleSize)/2,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        let nameLabelSize = CGSize(
                width: xpCircle.left - profileImageView.right - 25,
                height: height - 5
            )
        nameLabel.frame = CGRect(
            x: profileImageView.right + 9.92,
            y: 8,
            width: nameLabelSize.width,
            height: nameLabelSize.height
        )
        
        let buttonSize = CGSize(width: 80, height: 23)
        subscribeButton.frame = CGRect(
            x: width - buttonSize.width,
            y: 14,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = ""
        profileImageView.image = nil
        xpCircle.reset()
        
        subscribeButton.isHidden = true
    }
    
    public func configure(with viewModel: NewProfileViewModel) {
        
        profileImageView.frame.size = CGSize(width: 30, height: 30)
        nameLabel.font = UIFont(name: "Raleway-Heavy", size: 30)
        xpCircle.frame.size = CGSize(width: 30, height: 30)
        
        nameLabel.text = viewModel.nickname
        profileImageView.image = viewModel.profileImage
        subscribeButton.configure(for: viewModel.relationshipType, otherUserID: viewModel.userId)
        
        let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user)
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXP))
        xpCircle.setupFinished()
        
    }
    
}
