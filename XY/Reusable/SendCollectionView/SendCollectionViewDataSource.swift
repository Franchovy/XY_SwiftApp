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
    
    var data = [(UserViewModel, Bool)]()
    
    var filteredData: [(UserViewModel, Bool)] {
        get {
            if searchString == nil || searchString == "" {
                return data
            } else {
                return data.filter({$0.0.nickname.lowercased().contains(searchString!.lowercased())})
            }
        }
    }
    
    weak var delegate: SendToFriendCellDelegate?
    
    func reload() {
        data = FriendsDataManager.shared.friends.map({ ($0.toViewModel(), false) })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredData.count
    }
    
    func setSelected(id: ObjectIdentifier, selected: Bool) {
        if let index = data.firstIndex(where: { $0.0.coreDataID == id }) {
            data[index] = (data[index].0, selected)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SendCollectionViewCell.identifier, for: indexPath) as! SendCollectionViewCell
        
        cell.configure(with: filteredData[indexPath.row].0, isSendButtonPressed: filteredData[indexPath.row].1)
        
        cell.delegate = delegate
        
        return cell
    }
    
    public func setSearchString(_ searchString: String) {
        self.searchString = searchString
    }
}

