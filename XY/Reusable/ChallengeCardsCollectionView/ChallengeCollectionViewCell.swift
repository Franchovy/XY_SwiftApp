//
//  ChallengeCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class ChallengeCardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChallengeCardCollectionViewCell"
    
    private let colorLabel = ColorLabel()
    private var friendBubblesCollection = [FriendBubble]()
    private let imageView = UIImageView()
    private let centerLabel = Label(style: .body)
    private let nameLabel = Label(style: .bodyBold)
    private let timeLeftLabel = Label(style: .bodyBold)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(colorLabel)
        
        addSubview(centerLabel)
        addSubview(nameLabel)
        addSubview(timeLeftLabel)
        
        centerLabel.textColor = .white
        nameLabel.textColor = .white
        timeLeftLabel.textColor = .white
        
        for label in [centerLabel, nameLabel, timeLeftLabel] {
            label.textColor = .white
            label.layer.shadowRadius = 6
            label.layer.shadowOffset = CGSize(width: 0, height: 3)
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOpacity = 1.0
            label.layer.masksToBounds = false
        }
        
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        colorLabel.sizeToFit()
        colorLabel.frame = CGRect(
            x: 5,
            y: 5,
            width: colorLabel.width,
            height: colorLabel.height
        )
        
        centerLabel.sizeToFit()
        nameLabel.sizeToFit()
        timeLeftLabel.sizeToFit()
        
        let totalHeight:CGFloat = centerLabel.height + 5
            + nameLabel.height + 5
            + timeLeftLabel.height
        
        centerLabel.frame = CGRect(
            x: (width - centerLabel.width)/2,
            y: (height - totalHeight)/2,
            width: centerLabel.width,
            height: centerLabel.height
        )
        
        nameLabel.frame = CGRect(
            x: (width - nameLabel.width)/2,
            y: (height - totalHeight + 5 + centerLabel.height)/2,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        timeLeftLabel.frame = CGRect(
            x: (width - timeLeftLabel.width)/2,
            y: (height - totalHeight + 5 + centerLabel.height + 5 + nameLabel.height)/2,
            width: timeLeftLabel.width,
            height: timeLeftLabel.height
        )
        
        layoutFriendBubbles()
    }
    
    private func layoutFriendBubbles() {
        for (index, friendBubble) in friendBubblesCollection.enumerated() {
            friendBubble.frame = CGRect(
                x: 5 + CGFloat(index) * 12,
                y: colorLabel.bottom + 5,
                width: 24,
                height: 24
            )
        }
    }
    
    public func configure(with viewModel: ChallengeCollectionCellViewModel) {
        if let colorLabelViewModel = viewModel.colorLabel {
            colorLabel.isHidden = false
            colorLabel.setText(colorLabelViewModel.colorLabelText)
            colorLabel.setBackgroundColor(colorLabelViewModel.colorLabelColor)
        }
        if let friendsCollectionImages = viewModel.friendImages {
            friendsCollectionImages.forEach({ image in
                let friendBubble = FriendBubble()
                friendBubble.imageView.image = image
                friendBubblesCollection.append(friendBubble)
                addSubview(friendBubble)
            })
            
            layoutFriendBubbles()
        }
        
        imageView.image = viewModel.thumbnailImage
        
        if let playerName = viewModel.playerName {
            centerLabel.text = "Challenged by:"
            nameLabel.text = viewModel.playerName
        }
        timeLeftLabel.text = viewModel.timeLeft
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        colorLabel.isHidden = true
        
        friendBubblesCollection.forEach({ friendBubble in
            friendBubble.removeFromSuperview()
        })
        friendBubblesCollection = []
        
        centerLabel.text = nil
        nameLabel.text = nil
        timeLeftLabel.text = nil
    }
}
