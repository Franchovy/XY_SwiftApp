//
//  NotificationsCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

protocol NotificationCollectionViewCellDelegate: AnyObject {
    func notificationCellTappedPreview(with viewModel: NotificationViewModel)
}

class NotificationsCollectionViewCell: UICollectionViewCell {
    static let identifier = "NotificationsCollectionViewCell"
    
    private let nameLabel = Label(style: .nickname, fontSize: 15)
    private let textLabel = Label(style: .body, fontSize: 13)
    private let timestampLabel = Label(style: .bodyBold, fontSize: 12)
    private let friendBubble = FriendBubble()
    
    private var followButton: AddFriendButton?
    private var previewImage: ChallengeNotificationImage?
    
    var viewModel: NotificationViewModel?
    weak var delegate: NotificationCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(textLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(friendBubble)
        
        timestampLabel.alpha = 0.7
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendBubble.frame = CGRect(
            x: 10.25,
            y: 9.71,
            width: 50,
            height: 50
        )
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: friendBubble.right + 10,
            y: 10.14,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        textLabel.sizeToFit()
        textLabel.frame = CGRect(
            x: friendBubble.right + 10,
            y: nameLabel.bottom + 11.57,
            width: textLabel.width,
            height: textLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: textLabel.right + 5.5,
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
        
        viewModel = nil
        
        previewImage?.removeFromSuperview()
        previewImage = nil
        
        followButton?.removeFromSuperview()
        followButton = nil
    }
    
    public func configure(with viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.user.nickname
        textLabel.text = viewModel.notificationText
        timestampLabel.text = viewModel.timestampText
        friendBubble.configure(with: viewModel.user)
        
        switch viewModel.type {
        case .challengeAction:
            previewImage = ChallengeNotificationImage()
            if let image = viewModel.challengeImage {
                previewImage?.setImage(image)
            }
            contentView.addSubview(previewImage!)
            
            previewImage?.isUserInteractionEnabled = true
            previewImage?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
        case .challengeStatus(let challengeStatus):
            previewImage = ChallengeNotificationImage()
            if let image = viewModel.challengeImage {
                previewImage?.setImage(image)
            }
            previewImage?.setIcon(challengeStatus == .rejected ? .xmark : .check)
            contentView.addSubview(previewImage!)
            
            previewImage?.isUserInteractionEnabled = true
            previewImage?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
        case .friendStatus:
            followButton = AddFriendButton()
            followButton?.configure(with: viewModel.user)
            contentView.addSubview(followButton!)
            
            followButton?.translatesAutoresizingMaskIntoConstraints = false
            followButton?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            followButton?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
        
    }
    
    @objc private func didTapImageView() {
        guard let viewModel = viewModel else {
            return
        }
        delegate?.notificationCellTappedPreview(with: viewModel)
    }
}
