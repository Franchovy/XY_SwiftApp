//
//  MessageCell.swift
//  XY_APP
//
//  Created by Simone on 04/01/2021.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var timeLabelMessage: UILabel!
    @IBOutlet weak var textLabelMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        messageBubble.layer.cornerRadius = 10
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
