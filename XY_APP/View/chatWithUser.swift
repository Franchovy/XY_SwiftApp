//
//  chatWithUser.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import UIKit

class chatWithUser: UITableViewCell {
    
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var timeLabelChat: UILabel!
    @IBOutlet weak var textMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        chatBubble.layer.cornerRadius = chatBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
