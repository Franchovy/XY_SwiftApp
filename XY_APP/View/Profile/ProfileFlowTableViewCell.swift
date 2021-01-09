//
//  ProfileFlowTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class ProfileFlowTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    var postPrevCollection: [ProfilePostModel] = [
    
        ProfilePostModel(imagePostPrev: UIImage(named: "post_3")!),
        ProfilePostModel(imagePostPrev: UIImage(named: "post_2")!),
        ProfilePostModel(imagePostPrev: UIImage(named: "post_1")!),
        ProfilePostModel(imagePostPrev: UIImage(named: "post_3")!),
        ProfilePostModel(imagePostPrev: UIImage(named: "post_2")!),
        ProfilePostModel(imagePostPrev: UIImage(named: "post_1")!),
        
    
    ]
    
    @IBOutlet weak var flowLabel: UILabel!
    @IBOutlet weak var profileCollectionView:
        UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        profileCollectionView.dataSource = self
        profileCollectionView.register(UINib(nibName: "ProfileFlowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionPostReusable")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 118.33, height: 118.33)
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        self.profileCollectionView.collectionViewLayout = flowLayout
        self.profileCollectionView.showsHorizontalScrollIndicator = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ProfileFlowTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postPrevCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCollectionPostReusable", for: indexPath) as! ProfileFlowCollectionViewCell
        cell.postPicPreview.image = postPrevCollection[indexPath.row].imagePostPrev
        return cell
    }
    
    
    
}
