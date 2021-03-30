//
//  ChallengesDatasource.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

final class ChallengesManager: NSObject, UICollectionViewDataSource {
    
    let fakeData = [
        ChallengeCollectionCellViewModel(
            friendImages: [UIImage(named: "friend1")!, UIImage(named: "friend2")!],
            colorLabel: ColorLabelViewModel(colorLabelText: "Sent to", colorLabelColor: UIColor(0xFF0062)),
            timeLeft: nil,
            playerName: nil,
            videoURL: Bundle.main.url(forResource: "video1", withExtension: "mov")!
        ),
        ChallengeCollectionCellViewModel(
            friendImages: nil,
            colorLabel: ColorLabelViewModel(colorLabelText: "New", colorLabelColor: UIColor(0xCAF035)),
            timeLeft: "23H",
            playerName: "C3-TO",
            videoURL: Bundle.main.url(forResource: "video2", withExtension: "mov")!
        ),
        ChallengeCollectionCellViewModel(
            friendImages: nil,
            colorLabel: nil,
            timeLeft: "10H",
            playerName: "C3-0",
            videoURL: Bundle.main.url(forResource: "video3", withExtension: "mov")!
        ),
        ChallengeCollectionCellViewModel(
            friendImages: nil,
            colorLabel: ColorLabelViewModel(colorLabelText: "Expiring", colorLabelColor: UIColor(0xC6C6C6)),
            timeLeft: "1H",
            playerName: "Lorenzo Dabraio",
            videoURL: Bundle.main.url(forResource: "video4", withExtension: "mov")!
        ),
        ChallengeCollectionCellViewModel(
            friendImages: [UIImage(named: "friend4")!, UIImage(named: "friend5")!, UIImage(named: "friend1")!],
            colorLabel: ColorLabelViewModel(colorLabelText: "Sent to", colorLabelColor: UIColor(0xFF0062)),
            timeLeft: nil,
            playerName: nil,
            videoURL: Bundle.main.url(forResource: "video5", withExtension: "mov")!
        ),
    ]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCollectionViewCell.identifier, for: indexPath) as! ChallengeCollectionViewCell
        
        cell.configure(with: fakeData[indexPath.row])
        
        return cell
    }
    
    
}
