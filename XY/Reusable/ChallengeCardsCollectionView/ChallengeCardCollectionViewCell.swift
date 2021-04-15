//
//  ChallengeCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class ChallengeCardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChallengeCardCollectionViewCell"
    
    private let challengeCard = ChallengeCard()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(challengeCard)
        
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
        
        challengeCard.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

    public func configure(with viewModel: ChallengeCardViewModel) {
        challengeCard.configure(with: viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        challengeCard.reset()
    }
}
