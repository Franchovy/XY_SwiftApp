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
    
    var onlineFriendsHeader: [FriendsHeader] = [
    
        FriendsHeader(header: "Online Friends")
    ]
    
    override func viewDidLoad() {
    
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        xyworldTableView.dataSource = self
        xyworldTableView.register(UINib(nibName: "OnlineFriendsTVcell", bundle: nil), forCellReuseIdentifier: "onlineFriendsReusable")
        
        
        super.viewDidLoad()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

extension XYworldVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onlineFriendsReusable", for: indexPath) as? OnlineFriendsTVcell
        cell?.onlineFriendsLabel.text = onlineFriendsHeader[indexPath.row].header
        return cell!
    }

}


struct FriendsHeader {
    var header: String
}
