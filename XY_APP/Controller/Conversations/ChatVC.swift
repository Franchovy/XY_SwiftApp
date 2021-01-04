//
//  ChatVC.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import Foundation
import UIKit

class ChatVC : UIViewController {
    
    var userinfo: [ChatUserInfo] = [
        
        ChatUserInfo(ChatProfileImage: UIImage(named: "eo_profimg")!, ChatNameInfo: "Elizabeth Olsen")
    ]
    
    var messages: [MessagesChat] = [
    
        MessagesChat(messageText: "Hi baby 🥰", timeLabel: "1 min ago")
    
    ]
    
 
    @IBOutlet weak var chatTableView: UITableView!
   
    @IBOutlet weak var chatTextPlaceholder: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabBarController?.tabBar.isHidden = true
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        chatTextPlaceholder.backgroundColor = .clear
        chatTextPlaceholder.layer.borderWidth = 2
        chatTextPlaceholder.layer.cornerRadius = 15
        chatTextPlaceholder.layer.borderColor = UIColor.white.cgColor
        
        chatTableView.dataSource = self
        
        chatTableView.register(UINib(nibName: "UserInfoChat", bundle: nil), forCellReuseIdentifier: "senderDataReusable")
        
        chatTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageReusable")
  
    }
}

extension ChatVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "senderDataReusable", for: indexPath) as!
                UserInfoChat
            cell.chatProfImg.image = userinfo[indexPath.row].ChatProfileImage
            cell.chatNickString.text = userinfo[indexPath.row].ChatNameInfo
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageReusable", for: indexPath) as!
                MessageCell
            
            cell.timeLabelMessage.text = messages[indexPath.row - 1].timeLabel
            cell.textLabelMessage.text = messages[indexPath.row - 1].messageText
            cell.messageBubble.sizeToFit()
            return cell
        }
       
    }
    
    
    
}
