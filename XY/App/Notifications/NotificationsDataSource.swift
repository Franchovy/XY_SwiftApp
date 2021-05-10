//
//  NotificationsDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

final class NotificationsDataSource: NSObject, UICollectionViewDataSource {
    
    weak var delegate: NotificationCollectionViewCellDelegate?
    
    var data: [NotificationViewModel] = []
        
    func reload() {
        data = NotificationsDataManager.shared.notifications.map({ $0.toViewModel() }).sorted(by: { (viewModel1, viewModel2) -> Bool in
            return viewModel1.timestamp > viewModel2.timestamp
        })
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
