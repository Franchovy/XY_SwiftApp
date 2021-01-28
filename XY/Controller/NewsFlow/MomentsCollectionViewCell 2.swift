//
//  MomentsCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 30/12/2020.
//

import UIKit

class MomentsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MomentsImage: UIImageView!
    @IBOutlet weak var MomentsProfileImage: UIImageView!
    @IBOutlet weak var MomentsAlphaView: UIView!
    @IBOutlet weak var MomentsNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
        MomentsImage.layer.cornerRadius = 15
        MomentsProfileImage.layer.cornerRadius = 5
        MomentsAlphaView.layer.cornerRadius = 5
    }
    
    
    

}
