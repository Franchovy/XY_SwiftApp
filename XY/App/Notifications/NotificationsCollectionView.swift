//
//  NotificationsCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class NotificationsCollectionView: UICollectionView, UICollectionViewDelegate {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: 375, height: 70)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        delegate = self
        layer.masksToBounds = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        
        register(NotificationsCollectionViewCell.self, forCellWithReuseIdentifier: NotificationsCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! NotificationsCollectionViewCell
        
        guard let viewModel = cell.viewModel else {
            return
        }
        
        let vc = ProfileViewController()
        vc.configure(with: ProfileViewModel.randomProfileViewModel())
        
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
}
