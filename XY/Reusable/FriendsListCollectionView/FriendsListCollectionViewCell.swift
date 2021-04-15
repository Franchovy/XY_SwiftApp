//
//  FriendsListCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit


class FriendsListCollectionViewCell: UICollectionViewCell, FriendsDataManagerListener {
    
    static let identifier = "FriendsListCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .nickname)
    private let addFriendButton = AddFriendButton()
    
    var viewModel: UserViewModel?
    
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
    
    deinit {
        FriendsDataManager.shared.deregisterChangeListener(listener: self)
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friendBubble.imageView.image = nil
        nicknameLabel.text = nil
        
        viewModel = nil
        FriendsDataManager.shared.deregisterChangeListener(listener: self)
    }
    
    public func configure(with viewModel: UserViewModel) {
        self.viewModel = viewModel
        
        friendBubble.configure(with: viewModel)
        nicknameLabel.text = viewModel.nickname
        addFriendButton.configure(with: viewModel)
        
        FriendsDataManager.shared.registerChangeListener(for: viewModel, listener: self)
    }
    
    func didPressButtonForMode(mode: FriendStatus) {
        guard let viewModel = viewModel else {
            return
        }
        FriendsDataManager.shared.updateFriendStatus(friend: viewModel, newStatus: mode)
    }
    
    func didUpdateFriendshipState(to state: FriendStatus) {
        viewModel?.friendStatus = state
    }
}
