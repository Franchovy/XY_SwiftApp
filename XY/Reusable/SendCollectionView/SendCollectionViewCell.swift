//
//  SendCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class SendCollectionViewCell: UICollectionViewCell {
    static let identifier = "SendCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .nickname)
    private let addFriendButton = AddFriendButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(friendBubble)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(addFriendButton)
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
        addFriendButton.frame = CGRect(
            x: width - addFriendButton.width - 15,
            y: (height - addFriendButton.height)/2,
            width: addFriendButton.width,
            height: addFriendButton.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friendBubble.imageView.image = nil
        nicknameLabel.text = nil
        addFriendButton.configure(for: .none)
    }
    
    public func configure(with viewModel: SendCollectionViewCellViewModel) {
        friendBubble.setImage(viewModel.profileImage)
        nicknameLabel.text = viewModel.nickname
        addFriendButton.configure(for: viewModel.buttonStatus)
    }
}
