//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit

class ConversationsViewController: UIViewController {
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    let messages = [
        Conversation(username: "Maxime", message: "Yo Simone! Wake up!!"),
        Conversation(username: "Luca", message: "Where did you put my drugs")
    ]
   
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        conversationsTableView.layer.cornerRadius = 15.0
        
        conversationsTableView.dataSource = self

        conversationsTableView.register(UINib(nibName: K.conversationCellNibName, bundle: nil), forCellReuseIdentifier: K.conversationCellIdentifier)
    }
    
}
 
extension ConversationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // This function generates the cells for the tableview using the data that we provide inside Conversation struct
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationsTableView.dequeueReusableCell(withIdentifier: K.conversationCellIdentifier, for: indexPath) as! ConversationsCells
        
        cell.messageConversation.text = self.messages[indexPath.row].username
        cell.messageConversation.text = self.messages[indexPath.row].message
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width:1, height:1)
        cell.layer.shadowRadius = 1
        cell.layer.shadowOpacity = 1.0
        
        
        // todo get profile image and set the cell's profile image
        
        return cell
    }
}


