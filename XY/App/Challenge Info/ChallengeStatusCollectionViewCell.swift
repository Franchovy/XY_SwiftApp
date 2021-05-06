//
//  ChallengeStatusCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 06/05/2021.
//

import UIKit

class ChallengeStatusCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChallengeStatusCollectionViewCell"
    
    private let profileBubble = FriendBubble()
    private let nicknameLabel = Label(style: .info, fontSize: 20)
    private let challengeStatusView = ChallengeStatusView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileBubble.frame = CGRect(
            x: 5,
            y: 10,
            width: 50,
            height: 50
        )
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: profileBubble.right + 10,
            y: (height - nicknameLabel.height)/2,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        
        challengeStatusView.sizeToFit()
        challengeStatusView.frame = CGRect(
            x: width - challengeStatusView.width - 5,
            y: (height - challengeStatusView.height)/2,
            width: challengeStatusView.width,
            height: challengeStatusView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nicknameLabel.text = nil
        challengeStatusView.prepareForReuse()
        profileBubble.prepareForReuse()
    }
    
    public func configure(userViewModel: UserViewModel, status: ChallengeCompletionState) {
        nicknameLabel.text = userViewModel.nickname
        
        profileBubble.configure(with: userViewModel)
        challengeStatusView.configure(with: status)
    }
}
