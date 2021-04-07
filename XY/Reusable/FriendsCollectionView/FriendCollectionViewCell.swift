//
//  FriendCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    static let identifier = "FriendCollectionViewCell"
    
    private let friendBubble = FriendBubble()
    private let nicknameLabel = Label(style: .body)
    
    var viewModel: FriendBubbleViewModel?
    
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
    
    public func configure(with viewModel: FriendBubbleViewModel) {
        self.viewModel = viewModel
        
        friendBubble.setImage(viewModel.image)
        nicknameLabel.text = viewModel.nickname
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        friendBubble.imageView.image = nil
    }
}
