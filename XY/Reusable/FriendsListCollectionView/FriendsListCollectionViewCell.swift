//
//  FriendsListCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FriendsListCollectionViewCell: UICollectionViewCell {
    static let identifier = "FriendsListCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .nickname)
    private let addFriendButton = AddFriendButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(friendBubble)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(addFriendButton)
        
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        
        addFriendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        addFriendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendBubble.frame = CGRect(
            x: 10,
            y: 2.5,
            width: 50,
            height: 50
        )
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: friendBubble.right + 15,
            y: (height - nicknameLabel.height)/2,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        
        addFriendButton.sizeToFit()
        addFriendButton.layoutIfNeeded()
//        addFriendButton.frame = CGRect(
//            x: width - addFriendButton.width - 15,
//            y: (height - addFriendButton.height)/2,
//            width: addFriendButton.width,
//            height: addFriendButton.height
//        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friendBubble.imageView.image = nil
        nicknameLabel.text = nil
        addFriendButton.configure(for: .none)
    }
    
    public func configure(with viewModel: FriendListViewModel) {
        friendBubble.setImage(viewModel.profileImage)
        nicknameLabel.text = viewModel.nickname
        addFriendButton.configure(for: viewModel.buttonStatus)
    }
}
