//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit

class MessagesViewController: UIViewController {
    
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

        conversationsTableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
    
}
 
extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // This function generates the cells for the tableview using the data that we provide inside Conversation struct
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationsTableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! ConversationsCells
        
        cell.messageInCell.text = self.messages[indexPath.row].username
        cell.messageInCell.text = self.messages[indexPath.row].message
        // todo get profile image and set the cell's profile image
        
        return cell
    }
}


