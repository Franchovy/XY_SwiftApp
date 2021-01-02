//
//  FlowMomentsTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 30/12/2020.
//

import UIKit

class FlowMomentsTableViewCell: UITableViewCell  {
    
    
    var moments: [MomentsModel] = [
            
            MomentsModel(moment: UIImage(named: "Moments_Elon_Profile")!, momentsProfileImage: UIImage(named: "Moments_Elon")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon_Profile")!, momentsProfileImage: UIImage(named: "Moments_Elon")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon_Profile")!, momentsProfileImage: UIImage(named: "Moments_Elon")!, momentsName: "Elon Musk"),
            MomentsModel(moment: UIImage(named: "Moments_Elon_Profile")!, momentsProfileImage: UIImage(named: "Moments_Elon")!, momentsName: "Elon Musk")
        
        ]

    @IBOutlet weak var MomentsCollectionView: UICollectionView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MomentsCollectionView.dataSource = self
        
        MomentsCollectionView.register(UINib(nibName: "MomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "momentsIdentifier")
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
        return cell
    }
    
    
    
}
