//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit

class ConversationsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var conversationsTableView: UITableView!
    var conversation : [Conversations] = [
        
        Conversations(profileImage: UIImage(named: "maxime profile image")!, name: "Maxime Franchot" , message: "Hello maaaan", time: "1 min ago"),
        
        Conversations(profileImage: UIImage(named: "elonmusk_profilepicture")!, name: "Elon Musk" , message: "Bro i'm here in LA, join me", time: "10 min ago"),
        
   
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversationsTableView.dataSource = self
        conversationsTableView.layer.cornerRadius = 15.0
        conversationsTableView.delegate = self
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        registerCell()
    }
    
    func registerCell() {
        
        conversationsTableView.register(UINib(nibName: "WaitingButton", bundle: nil), forCellReuseIdentifier: "waitingCell")
        
        conversationsTableView.register(UINib(nibName: "ConversationChat", bundle: nil), forCellReuseIdentifier: "ReusableCell")

    }
}

extension ConversationsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // + 1 to include waiting button
        return conversation.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        // If this is the first cell then add the waiting button
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "waitingCell", for: indexPath) as! WaitingButton
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ConversationChat
        cell.messageReceived.text = conversation[indexPath.row - 1].message
        cell.nameSender.text = conversation[indexPath.row - 1].name
        cell.senderImage.image = conversation[indexPath.row - 1].profileImage
        cell.timeLabel.text = conversation[indexPath.row - 1].time
        return cell
   
        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ConversationChat
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        performSegue(withIdentifier: "conversationToChat", sender: self)
    }
}
