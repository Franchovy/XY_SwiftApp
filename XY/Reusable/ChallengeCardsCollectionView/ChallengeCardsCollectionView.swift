//
//  ChallengesCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit



class ChallengeCardsCollectionView: UICollectionView, UICollectionViewDelegate {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 170, height: 267)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(ChallengeCardCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeCardCollectionViewCell.identifier)
        
        backgroundColor = .clear
        layer.masksToBounds = false
        
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let challengeCard = collectionView.cellForItem(at: indexPath) as? ChallengeCardCollectionViewCell else {
            return
        }
        
        let watchVC = WatchViewController()
        NavigationControlManager.mainViewController.navigationController?.pushViewController(watchVC, animated: true)
    }
}
