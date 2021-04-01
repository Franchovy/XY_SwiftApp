//
//  NotificationsCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class NotificationsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NotificationsCollectionViewCell"
    
    private let nameLabel = Label(style: .nickname, fontSize: 15)
    private let textLabel = Label(style: .body, fontSize: 13)
    private let timestampLabel = Label(style: .bodyBold, fontSize: 12)
    private let imageView = FriendBubble()
    
    private var followButton: AddFriendButton?
    private var previewImage: ChallengeNotificationImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(textLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(
            x: 10.25,
            y: 9.71,
            width: 50,
            height: 50
        )
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: imageView.right + 10,
            y: 10.14,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        textLabel.sizeToFit()
        textLabel.frame = CGRect(
            x: imageView.right + 10,
            y: nameLabel.bottom + 11.57,
            width: textLabel.width,
            height: textLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: textLabel.right + 2.5,
            y: nameLabel.bottom + 12.5,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
        
        if let previewImage = previewImage {
            previewImage.frame = CGRect(
                x: width - 50 - 10,
                y: 10,
                width: 50,
                height: 50
            )
        }
        
        if let followButton = followButton {
            followButton.sizeToFit()
            followButton.frame = CGRect(
                x: width - 10 - followButton.width,
                y: (height - followButton.height)/2,
                width: followButton.width,
                height: followButton.height
            )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        previewImage?.removeFromSuperview()
        previewImage = nil
        
        followButton?.removeFromSuperview()
        followButton = nil
    }
    
    public func configure(with viewModel: NotificationViewModel) {
        nameLabel.text = viewModel.nickname
        textLabel.text = viewModel.notificationText
        timestampLabel.text = viewModel.timestampText
        imageView.setImage(viewModel.profileImage)
        
        switch viewModel.type {
        case .challengeAction(let image):
            previewImage = ChallengeNotificationImage()
            previewImage?.setImage(image)
            contentView.addSubview(previewImage!)
        case .challengeStatus(let image, let status):
            previewImage = ChallengeNotificationImage()
            previewImage?.setImage(image)
            previewImage?.setIcon(status ? .check : .xmark)
            contentView.addSubview(previewImage!)
        case .friendStatus(let status):
            followButton = AddFriendButton()
            followButton?.configure(for: status)
            contentView.addSubview(followButton!)
        }
        
    }
}
