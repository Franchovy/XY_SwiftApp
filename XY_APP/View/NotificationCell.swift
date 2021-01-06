//
//  NotificationCell.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var NotificationProfImg: UIImageView!
    
    @IBOutlet weak var NotNick: UILabel!
    
    @IBOutlet weak var NotLabel: UILabel!
    
    @IBOutlet weak var NotContainer: UIView!
    
    @IBOutlet weak var NotPostPrev: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotContainer.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
