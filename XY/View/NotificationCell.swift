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

    func configure(with model: NotificationViewModel) {
        NotificationProfImg.image = model.displayImage
        NotPostPrev.image = model.previewImage
        NotNick.text = model.title
        NotLabel.text = model.text
        
    }
    
    override func prepareForReuse() {
        
    }
}
