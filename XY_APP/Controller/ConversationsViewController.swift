//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit

class ConversationsViewController: UIViewController{
    
    @IBOutlet weak var conversationTableView: UITableView!
    
    
    let conversations = [Conversations(name: "Luca", message: "Ciao Simo", time: "2 min ago"),
                         Conversations(name: "Elon Musk", message: "Ilove XY", time: "1 min ago")
                         
]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
    }
}

