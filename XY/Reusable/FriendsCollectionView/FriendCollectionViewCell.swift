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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(friendBubble)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendBubble.frame = bounds
    }
    
    public func configure(with image: UIImage) {
        friendBubble.setImage(image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}