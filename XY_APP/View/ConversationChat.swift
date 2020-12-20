//
//  ConversationChat.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import UIKit

class ConversationChat: UITableViewCell {
   
    @IBOutlet weak var conversationContainer: UIView!
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var nameSender: UILabel!
    @IBOutlet weak var messageReceived: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        conversationContainer.layer.cornerRadius = 15.0
        conversationContainer.layer.shadowColor = UIColor.black.cgColor
        conversationContainer.layer.shadowOffset = CGSize(width:1, height:1)
        conversationContainer.layer.shadowRadius = 1
        conversationContainer.layer.shadowOpacity = 1.0
    }
    
}
