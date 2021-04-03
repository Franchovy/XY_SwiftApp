//
//  SendCollectionViewDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

final class SendCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    override init() {
        filteredData = fakeData
    }
    
    var searchString: String?
    
    let fakeData = [
        SendCollectionViewCellViewModel(profileImage: UIImage(named: "friend1")!, nickname: "friend1", buttonStatus: .add),
        SendCollectionViewCellViewModel(profileImage: UIImage(named: "friend2")!, nickname: "friend2", buttonStatus: .added),
        SendCollectionViewCellViewModel(profileImage: UIImage(named: "friend3")!, nickname: "friend3", buttonStatus: .friend),
        SendCollectionViewCellViewModel(profileImage: UIImage(named: "friend4")!, nickname: "friend4", buttonStatus: .addBack),
        SendCollectionViewCellViewModel(profileImage: UIImage(named: "friend5")!, nickname: "friend5", buttonStatus: .friend)
    ]
    
    var filteredData = [SendCollectionViewCellViewModel]()
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SendCollectionViewCell.identifier, for: indexPath) as! SendCollectionViewCell
        
        cell.configure(with: filteredData[indexPath.row])
        
        return cell
    }
    
    public func setSearchString(_ searchString: String) {
        self.searchString = searchString
        filterDataBySearch()
    }
}

