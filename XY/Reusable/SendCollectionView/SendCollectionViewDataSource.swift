//
//  SendCollectionViewDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

final class SendCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    override init() { }
    
    var searchString: String?
    
    var data = [UserViewModel]()
    
    var filteredData: [UserViewModel] {
        get {
            if searchString == nil || searchString == "" {
                return data
            } else {
                return data.filter({$0.nickname.lowercased().contains(searchString!.lowercased())})
            }
        }
    }
    
    weak var delegate: SendToFriendCellDelegate?
    
    func reload() {
        data = FriendsDataManager.shared.friends.map({ $0.toViewModel() })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SendCollectionViewCell.identifier, for: indexPath) as! SendCollectionViewCell
        
        cell.configure(with: filteredData[indexPath.row])
        cell.delegate = delegate
        
        return cell
    }
    
    public func setSearchString(_ searchString: String) {
        self.searchString = searchString
    }
}

