//
//  FlowMomentsTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 30/12/2020.
//

import UIKit

class FlowMomentsTableViewCell: UITableViewCell, FlowDataCell {
    var type: FlowDataType = .momentsCollection
    
    var moments: [MomentsModel] = [
            
            MomentsModel(moment: UIImage(named: "Moments_Elon")!, momentsProfileImage: UIImage(named: "Moments_Elon_Profile")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon")!, momentsProfileImage: UIImage(named: "Moments_Elon_Profile")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon")!, momentsProfileImage: UIImage(named: "Moments_Elon_Profile")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon")!, momentsProfileImage: UIImage(named: "Moments_Elon_Profile")!, momentsName: "Elon Musk")
        
        ]
    
    static let reusableIdentifier = "MomentsCell"

    @IBOutlet weak var MomentsCollectionView: UICollectionView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MomentsCollectionView.dataSource = self
        
        MomentsCollectionView.register(UINib(nibName: "MomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "momentsIdentifier")
        layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension FlowMomentsTableViewCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "momentsIdentifier", for: indexPath) as! MomentsCollectionViewCell
        cell.MomentsImage.image = moments[indexPath.row].moment
        cell.MomentsProfileImage.image = moments[indexPath.row].momentsProfileImage
        return cell
    }
}
