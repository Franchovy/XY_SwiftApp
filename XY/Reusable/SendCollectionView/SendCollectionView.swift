//
//  SendCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class SendCollectionView: UICollectionView, UICollectionViewDelegate {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.estimatedItemSize = CGSize(width: 375, height: 55)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        alwaysBounceVertical = true
        
        delegate = self
        register(SendCollectionViewCell.self, forCellWithReuseIdentifier: SendCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
