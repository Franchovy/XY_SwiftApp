//
//  ChallengesDatasource.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

final class ChallengesDataSource: NSObject, UICollectionViewDataSource {
    
    var challengesData:[ChallengeCardViewModel] = []
    
    public func reload() {
        challengesData = ChallengeDataManager.shared.activeChallenges.map({
            $0.toCard()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCardCollectionViewCell.identifier, for: indexPath) as! ChallengeCardCollectionViewCell
        
        cell.configure(with: challengesData[indexPath.row])
        
        return cell
    }
    
}
