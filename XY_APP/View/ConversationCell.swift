//
//  ConversationCell.swift
//  XY_APP
//
//  Created by Simone on 03/01/2021.
//

import UIKit

class ConversationCell: UITableViewCell {

    @IBOutlet weak var convView: UIView!
    @IBOutlet weak var convProfImg: UIImageView!
    @IBOutlet weak var convSenderNick: UILabel!
    @IBOutlet weak var convMsgPrev: UILabel!
    @IBOutlet weak var convTimePrev: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        convView.layer.cornerRadius = 15
        convProfImg.layer.cornerRadius = convProfImg.frame.size.width/2
        convProfImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
