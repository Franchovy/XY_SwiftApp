//
//  FriendsCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendsCollectionView: UICollectionView, UICollectionViewDelegate {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 70, height: 70)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        delegate = self
        register(EditProfileCollectionViewCell.self, forCellWithReuseIdentifier: EditProfileCollectionViewCell.identifier)
        register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: FriendCollectionViewCell.identifier)
        
        layer.masksToBounds = false
        
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateImpact(for: .medium)
        
        if indexPath.row == 0 {
            let vc = EditProfileViewController()
            
            NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! FriendCollectionViewCell
            guard let viewModel = cell.viewModel else {
                return
            }
            
            NavigationControlManager.presentProfileViewController(with: ProfileViewModel.randomProfileViewModel(basedOn: (viewModel.nickname, viewModel.image)))
        }
    }
}
