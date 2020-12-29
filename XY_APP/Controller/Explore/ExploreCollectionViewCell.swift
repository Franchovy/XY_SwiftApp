//
//  ExploreCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MomentsPreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MomentsPreview.layer.cornerRadius = 10
    }

}
