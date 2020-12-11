//
//  ConversationsCells.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import UIKit

class ConversationsCells: UITableViewCell {

    @IBOutlet weak var messageCell: UIView!
    @IBOutlet weak var profileImageCell: UIImageView!
    
    @IBOutlet weak var xynameLabelMessageCell: UILabel!
    
    @IBOutlet weak var messageInCell: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageCell.layer.cornerRadius = messageCell.frame.size.height / 4
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
