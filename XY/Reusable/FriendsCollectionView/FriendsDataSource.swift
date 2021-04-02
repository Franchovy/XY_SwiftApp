//
//  FriendsDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {

    let fakeData:[UIImage] = [
        UIImage(named: "friend4")!,
        UIImage(named: "friend1")!,
        UIImage(named: "friend3")!,
        UIImage(named: "friend2")!,
        UIImage(named: "friend5")!
    ]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditProfileCollectionViewCell.identifier, for: indexPath) as! EditProfileCollectionViewCell
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCollectionViewCell.identifier, for: indexPath) as! FriendCollectionViewCell
            
            cell.configure(with: fakeData[indexPath.row-1])
            
            return cell
        }
    }
    
    
}
