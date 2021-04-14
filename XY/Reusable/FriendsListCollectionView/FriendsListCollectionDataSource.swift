//
//  FriendsListCollectionDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FriendsListCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    override init() { }
    
    var searchString: String?
    
    var data: [FriendListViewModel] = []
    var filteredData:[FriendListViewModel] {
        get {
            if let searchString = searchString {
                if searchString == "" {
                    return data
                } else {
                    return data.filter({$0.nickname.lowercased().contains(searchString.lowercased())})
                }
            } else {
                return data
            }
        }
    }
    
    func loadFromData() {
        data = FriendsDataManager.shared.allUsers.map({ $0.toFriendListViewModel() })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsListCollectionViewCell.identifier, for: indexPath) as! FriendsListCollectionViewCell
        
        cell.configure(with: filteredData[indexPath.row])
        
        return cell
    }
    
    public func setSearchString(_ searchString: String) {
        self.searchString = searchString
    }
}
