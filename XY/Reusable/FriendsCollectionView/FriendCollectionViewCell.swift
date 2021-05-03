//
//  FriendCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell, FriendsDataManagerListener {
    
    static let identifier = "FriendCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .body)
    
    var viewModel: UserViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(friendBubble)
        addSubview(nicknameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendBubble.frame = bounds
        
        nicknameLabel.sizeToFit()
        let labelWidth = min(nicknameLabel.width, width)
        
        nicknameLabel.frame = CGRect(
            x: (width - labelWidth)/2,
            y: friendBubble.bottom + 5,
            width: labelWidth,
            height: nicknameLabel.height
        )
    }
    
    public func configure(with viewModel: UserViewModel) {
        self.viewModel = viewModel
        
        friendBubble.configure(with: viewModel)
        nicknameLabel.text = viewModel.nickname
        
        FriendsDataManager.shared.registerChangeListener(for: viewModel, listener: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        friendBubble.imageView.image = nil
        FriendsDataManager.shared.deregisterChangeListener(listener: self)
    }
    
    func didUpdateFriendshipState(to state: FriendStatus) {
        viewModel?.friendStatus = state
    }
    
    func didUpdateProfileImage(to image: UIImage) {
        friendBubble.imageView.image = image
        viewModel?.profileImage = image
    }
    
    func didUpdateNickname(to nickname: String) {
        nicknameLabel.text = nickname
        viewModel?.nickname = nickname
    }
    
    func didUpdateNumFriends(to numFriends: Int) {
        
    }
    
    func didUpdateNumChallenges(to numChallenges: Int) {
        
    }
}
