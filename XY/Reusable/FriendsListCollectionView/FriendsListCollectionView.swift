//
//  FriendsListCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FriendsListCollectionView: UICollectionView, UICollectionViewDelegate {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: 375, height: 55)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        alwaysBounceVertical = true
        
        delegate = self
        register(FriendsListCollectionViewCell.self, forCellWithReuseIdentifier: FriendsListCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? FriendsListCollectionViewCell, let viewModel = item.viewModel else {
            return
        }
        
        NavigationControlManager.presentProfileViewController(with: viewModel)
    }
}
