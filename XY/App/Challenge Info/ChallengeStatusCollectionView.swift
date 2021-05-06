//
//  ChallengeStatusCollectionView.swift
//  XY
//
//  Created by Maxime Franchot on 06/05/2021.
//

import UIKit

class ChallengeStatusCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userStatus: [(UserViewModel, ChallengeCompletionState)] = []
    
    public func configure(with viewModel: ChallengeCardViewModel) {
        guard let challengeID = viewModel.coreDataID else {
            return
        }
        // fetch user members and respective status
        ChallengeDataManager.shared.getChallengeStatuses(for: challengeID) { (statuses) in
            self.userStatus = statuses.map({ ($0.0.toViewModel(), $0.1) })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeStatusCollectionViewCell.identifier, for: indexPath) as! ChallengeStatusCollectionViewCell
        
        cell.configure(userViewModel: userStatus[indexPath.row].0, status: userStatus[indexPath.row].1)
        
        return cell
    }
}
