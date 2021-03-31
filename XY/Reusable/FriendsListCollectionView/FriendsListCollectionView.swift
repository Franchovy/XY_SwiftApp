//
//  FriendsListCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FriendsListCollectionView: UICollectionView {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.estimatedItemSize = CGSize(width: 375, height: 55)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        alwaysBounceVertical = true
        
        register(FriendsListCollectionViewCell.self, forCellWithReuseIdentifier: FriendsListCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
