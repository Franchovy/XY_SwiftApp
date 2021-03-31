//
//  FriendsListCollectionDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FriendsListCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    override init() {
        filteredData = fakeData
    }
    
    var searchString: String?
    
    let fakeData = [
        FriendListViewModel(profileImage: UIImage(named: "friend1")!, nickname: "friend1", buttonStatus: .add),
        FriendListViewModel(profileImage: UIImage(named: "friend2")!, nickname: "friend2", buttonStatus: .added),
        FriendListViewModel(profileImage: UIImage(named: "friend3")!, nickname: "friend3", buttonStatus: .friend),
        FriendListViewModel(profileImage: UIImage(named: "friend4")!, nickname: "friend4", buttonStatus: .addBack),
        FriendListViewModel(profileImage: UIImage(named: "friend5")!, nickname: "friend5", buttonStatus: .friend)
    ]
    
    var filteredData = [FriendListViewModel]()
    
    private func filterDataBySearch() {
        guard let searchString = searchString else {
            filteredData = fakeData
            return
        }
        
        if searchString == "" {
            filteredData = fakeData
        } else {
            filteredData = fakeData.filter({$0.nickname.lowercased().contains(searchString.lowercased())})
        }
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
        filterDataBySearch()
    }
}
