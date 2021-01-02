//
//  ExploreCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var momentsPreview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        momentsPreview.layer.cornerRadius = 5
    }

}
