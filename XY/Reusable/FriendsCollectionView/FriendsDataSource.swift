//
//  FriendsDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {
    
    var data: [UserViewModel]
    var showEditProfile: Bool = false
    
    init(fromList list: [UserViewModel]) {
        data = list
        showEditProfile = false
        
        super.init()
    }
    
    override init() {
        data = []
        super.init()
    }
    
    func reload() {
        data = FriendsDataManager.shared.friends.map({ $0.toViewModel() })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count + (showEditProfile ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0, showEditProfile {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditProfileCollectionViewCell.identifier, for: indexPath) as! EditProfileCollectionViewCell
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCollectionViewCell.identifier, for: indexPath) as! FriendCollectionViewCell
            
            cell.configure(with: data[indexPath.row - (showEditProfile ? 1 : 0)])
            
            return cell
        }
    }
}
