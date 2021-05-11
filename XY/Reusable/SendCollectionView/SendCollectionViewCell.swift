//
//  SendCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

protocol SendToFriendCellDelegate: AnyObject {
    func sendToFriendCell(selectedCellWith viewModel: UserViewModel)
    func sendToFriendCell(deselectedCellWith viewModel: UserViewModel)
}

class SendCollectionViewCell: UICollectionViewCell {
    static let identifier = "SendCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .nickname)
    private let sendButton = SendButton()
    
    var viewModel: UserViewModel?
    weak var delegate: SendToFriendCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(friendBubble)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(sendButton)
        
        sendButton.addTarget(self, action: #selector(tappedSendButton), for: .touchUpInside)
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
        
        sendButton.sizeToFit()
        sendButton.frame = CGRect(
            x: width - sendButton.width - 15,
            y: (height - sendButton.height)/2,
            width: sendButton.width,
            height: sendButton.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friendBubble.imageView.image = nil
        nicknameLabel.text = nil
    }
    
    public func setIsPressed(_ isPressed: Bool) {
        sendButton.isPressed = isPressed
        sendButton.configureForPressMode()
    }
    
    public func configure(with viewModel: UserViewModel, isSendButtonPressed: Bool) {
        self.viewModel = viewModel
        
        friendBubble.configure(with: viewModel)
        nicknameLabel.text = viewModel.nickname
        
        sendButton.configurePressed(isPressed: isSendButtonPressed)
    }
    
    @objc private func tappedSendButton() {
        guard let viewModel = viewModel else {
            return
        }
        
        if sendButton.isPressed {
            delegate?.sendToFriendCell(deselectedCellWith: viewModel)
        } else {
            delegate?.sendToFriendCell(selectedCellWith: viewModel)
        }
    }
}
