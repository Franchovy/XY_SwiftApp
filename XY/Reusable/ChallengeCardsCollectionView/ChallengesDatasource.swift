//
//  ChallengesDatasource.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

final class ChallengesManager: NSObject, UICollectionViewDataSource {
    
    let fakeData = ChallengeCardViewModel.fakeData
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCardCollectionViewCell.identifier, for: indexPath) as! ChallengeCardCollectionViewCell
        
        cell.configure(with: fakeData[indexPath.row])
        
        return cell
    }
    
}
