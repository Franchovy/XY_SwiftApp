//
//  NotificationsDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

final class NotificationsDataSource: NSObject, UICollectionViewDataSource {
    
    weak var delegate: NotificationCollectionViewCellDelegate?
    
    let data: [NotificationViewModel] = []
        
    func load() {
        NotificationsDataManager.shared.fetchNotifications()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationsCollectionViewCell.identifier, for: indexPath) as! NotificationsCollectionViewCell
        
        cell.configure(with: data[indexPath.row])
        
        assert(delegate != nil, "NotificationsDataSource delegate has not been set!")
        cell.delegate = delegate
        
        return cell
    }
    
    
}
