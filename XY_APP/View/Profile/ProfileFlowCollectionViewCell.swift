//
//  ProfileFlowCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class ProfileFlowCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postPicPreview: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postPicPreview.layer.cornerRadius = 15
    }

}
