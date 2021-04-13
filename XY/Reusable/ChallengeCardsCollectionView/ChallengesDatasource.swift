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
            
            ChallengeCardViewModel(
                image: UIImage(data: $0.previewImage)!,
                title: $0.title,
                description: $0.description,
                tag: nil,
                timeLeftText: "\($0.expireTimestamp.hoursFromNow())H",
                isReceived: true,
                friendBubbles: nil,
                senderProfile: FriendsDataManager.shared.getBubbleFromData(dataModel: $0.fromUser)
            )
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
