//
//  suggestedCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 10/01/2021.
//

import UIKit

class suggestedCollectionViewCell:
    
    UICollectionViewCell {
    @IBOutlet weak var suggestedPrevMoment: UIImageView!
    @IBOutlet weak var suggestedProfPic: UIImageView!
    @IBOutlet weak var suggestedXYname: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        suggestedProfPic.layer.cornerRadius = suggestedProfPic.frame.size.width/2
        suggestedProfPic.clipsToBounds = true
        suggestedProfPic.layer.borderColor = UIColor.red.cgColor
        suggestedProfPic.layer.borderWidth = 3.0
        
        suggestedPrevMoment.layer.cornerRadius = 10
    }

}
