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
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinkMessageBubble: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        messageBubble.layer.cornerRadius = 10
        textLabelMessage.frame.size = textLabelMessage.intrinsicContentSize
        widthConstraint.constant = textLabelMessage.intrinsicContentSize.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
