//
//  ChatVC.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import Foundation
import UIKit

class ChatVC : UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!

    var chat: [Chat] = [
    
        Chat(time: "1 min ago", body: "Hey Bro!"),
        Chat(time: "10 min ago", body: "See you in LA"),
        Chat(time: "15 min ago", body: "How are you")
        
    
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.layer.cornerRadius = 15.0
        
        chatTableView.register(UINib(nibName: "chatWithUser", bundle: nil), forCellReuseIdentifier: "ChatReusableCell")
    }
}


extension ChatVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReusableCell", for: indexPath) as! chatWithUser
        cell.textMessage.text = chat[indexPath.row].body
        return cell
   
    }

}

//quando una cell viene cliccata in una raw il codice viene triggerato, quindi potrei performare qui il segue perché la current class è delegate
extension ChatVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}
