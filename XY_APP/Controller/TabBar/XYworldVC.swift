//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

class XYworldVC: UIViewController {
    
    
    @IBOutlet var xyworldTableView: UITableView!

    var onlineFriends: [OnlineFriendsModel] = [
    
        OnlineFriendsModel(label: "Online Now")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        xyworldTableView.dataSource = self
        let cellNib = UINib(nibName: "OnlineFriendsTableViewCell", bundle: nil)
                self.xyworldTableView.register(cellNib, forCellReuseIdentifier: "tableviewcellidOnline")

    }
    
}

extension XYworldVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellidOnline", for: indexPath) as! OnlineFriendsTableViewCell
        cell.onlineFriendsLabel.text = onlineFriends[indexPath.row].label
        return cell
    }
    
}

