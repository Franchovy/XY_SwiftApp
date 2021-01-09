//
//  OnlineFriendsCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class OnlineFriendsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var OnlineCircleView: CircleView!
    @IBOutlet weak var OnlineFriendImage: UIImageView!
    @IBOutlet weak var whereIsYourFriendLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        OnlineFriendImage.layer.masksToBounds = false
        OnlineFriendImage.layer.cornerRadius = OnlineFriendImage.frame.height/2
        OnlineFriendImage.clipsToBounds = true
    }

}
