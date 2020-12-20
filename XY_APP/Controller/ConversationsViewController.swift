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
    var conversation : [Conversations] = [
    
        Conversations(profileImage:"maxime profile image", name: "Elon Musk" , message: "Hello maaaan", time: "1 min ago"),
        
        Conversations(profileImage: "maxime profile image", name: "Maxime Franchot" , message: "Bro let's go run ", time: "2 mins ago"),
         
        Conversations(profileImage: "maxime profile image", name: "Diana" , message: "Remmeber to take the umbrella", time: "3 mins ago")
    
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversationsTableView.dataSource = self
        conversationsTableView.layer.cornerRadius = 15.0
        
       

        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
    }
}

extension ConversationsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        cell.textLabel?.text = "This is a conversation"
        return cell
    }
    
    
    
}

