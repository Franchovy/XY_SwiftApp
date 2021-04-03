//
//  ChallengesCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class ChallengeCardsCollectionView: UICollectionView {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 125, height: 200)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(ChallengeCardCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeCardCollectionViewCell.identifier)
        
        backgroundColor = .clear
        layer.masksToBounds = false
        
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
