//
//  OnlineFriendsTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class OnlineFriendsTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    var onlineFriendsRow: [OnlineFriendsCellsModel] = [
    
        OnlineFriendsCellsModel(OFimage: UIImage(named: "simone_onlline")!, OFwhere: "Flow"),
        OnlineFriendsCellsModel(OFimage: UIImage(named: "maxime_online")!, OFwhere: "Profile"),
        OnlineFriendsCellsModel(OFimage: UIImage(named: "zuck_online")!, OFwhere: "Reporting"),
        OnlineFriendsCellsModel(OFimage: UIImage(named: "elizabeth_online")!, OFwhere: "Chatting")
        
    ]
    
    @IBOutlet weak var onlineFriendsLabel: UILabel!
    @IBOutlet weak var onlineFriendsCollectionView: UICollectionView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onlineFriendsCollectionView.dataSource = self
        onlineFriendsCollectionView.delegate = self

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 125)
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 10.0
        self.onlineFriendsCollectionView.collectionViewLayout = flowLayout
        self.onlineFriendsCollectionView.showsHorizontalScrollIndicator = false
        
        let cellNib = UINib(nibName: "OnlineFriendsCollectionViewCell", bundle: nil)
        self.onlineFriendsCollectionView.register(cellNib, forCellWithReuseIdentifier: "collectionviewcellidOnline")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension OnlineFriendsTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onlineFriendsRow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcellidOnline", for: indexPath) as! OnlineFriendsCollectionViewCell
        cell.OnlineFriendImage.image = onlineFriendsRow[indexPath.row].OFimage
        cell.whereIsYourFriendLabel.text = onlineFriendsRow[indexPath.row].OFwhere
        return cell
    }
    
}
