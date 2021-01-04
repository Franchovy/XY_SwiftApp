//
//  UserInfoChat.swift
//  XY_APP
//
//  Created by Simone on 04/01/2021.
//

import UIKit

class UserInfoChat: UITableViewCell {

    @IBOutlet weak var chatProfImg: UIImageView!
    @IBOutlet weak var chatNickString: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatProfImg.layer.cornerRadius = chatProfImg.frame.height/2
        chatProfImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
