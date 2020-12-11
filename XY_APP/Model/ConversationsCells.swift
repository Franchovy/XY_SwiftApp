//
//  ConversationsCells.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import UIKit

class ConversationsCells: UITableViewCell {
    @IBOutlet weak var bubbleCell: UIView!
    
    @IBOutlet weak var messageInCell: UILabel!
    @IBOutlet weak var profilePhotoInMessage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.layer.cornerRadius = 7
        self.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    }
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        
        bubbleCell.layer.cornerRadius = bubbleCell.frame.size.height / 4
        
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
