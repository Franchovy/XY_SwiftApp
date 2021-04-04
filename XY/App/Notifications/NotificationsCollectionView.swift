//
//  NotificationsCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class NotificationsCollectionView: UICollectionView, UICollectionViewDelegate, NotificationCollectionViewCellDelegate {

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
        vc.configure(with: ProfileViewModel.randomProfileViewModel(basedOn: (viewModel.nickname, viewModel.profileImage)))
        
        HapticsManager.shared.vibrateImpact(for: .light)
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func notificationCellTappedPreview(with viewModel: NotificationViewModel) {
        switch viewModel.type {
        case .challengeAction(let image):
            let vc = CreateChallengeViewController()
            
            HapticsManager.shared.vibrateImpact(for: .light)
            NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
        case .challengeStatus(let image, let status):
            break
        default:
            break
        }
    }
    
}
