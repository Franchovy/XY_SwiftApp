//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit


class ConversationsVC: UIViewController {
    
    
    var conversations: [ConversationPreview] = [ ]
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        conversationsTableView.delegate = self
        
        conversationsTableView.layer.cornerRadius = 15
        conversationsTableView.dataSource = self
        conversationsTableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "conversationReusableCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Conversation messages data
        //TODO
        let cell = tableView.cellForRow(at: indexPath) as! ConversationCell
        let userId = cell.convSenderNick
        
        // Segue to chat
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: ChatVC.identifier) as! ChatVC
        present(vc, animated: true) {
            print("Loading data for chat: \(userId)")
        }
    }
    
    
}
