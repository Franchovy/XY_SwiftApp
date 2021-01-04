//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit

class ConversationsVC: UIViewController {
    
    
    var conversations: [ConversationPreview] = [
        
        ConversationPreview(senderImage: UIImage(named: "Not_1")!, senderName: "Elizabeth Olsen", messagePreview: "Waiting you baby", time: "1 min ago"),
        
        ConversationPreview(senderImage: UIImage(named: "Not_1")!, senderName: "Elizabeth Olsen", messagePreview: "Waiting you baby", time: "1 min ago"),
        
        ConversationPreview(senderImage: UIImage(named: "Not_1")!, senderName: "Elizabeth Olsen", messagePreview: "Waiting you baby", time: "1 min ago"),
        
        ConversationPreview(senderImage: UIImage(named: "Not_1")!, senderName: "Elizabeth Olsen", messagePreview: "Waiting you baby", time: "1 min ago"),
        
    ]
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        conversationsTableView.layer.cornerRadius = 15
        conversationsTableView.dataSource = self
        conversationsTableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "conversationReusableCell")
        
    }
}


extension ConversationsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    {
        
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationReusableCell", for: indexPath) as! ConversationCell
        cell.convProfImg.image = conversations[indexPath.row].senderImage
        cell.convSenderNick.text = conversations[indexPath.row].senderName
        cell.convMsgPrev.text = conversations[indexPath.row].messagePreview
        cell.convTimePrev.text = conversations[indexPath.row].time
        return cell
        
    }
}

extension ConversationsVC : UITableViewDelegate {
    
    
}
