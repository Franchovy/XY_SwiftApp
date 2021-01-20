//
//  NotificationsVC.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications: [Notification] = [
        
        Notification(NotificationProfileImage: UIImage(named: "Not_1")!, NotificationPostPreview: UIImage(named: "not_2")!, NotificationName: "Elizabeth Olsen", NotificationLabel: "Swiped Right your post!"),
        
        Notification(NotificationProfileImage: UIImage(named: "Not_1")!, NotificationPostPreview: UIImage(named: "not_2")!, NotificationName: "Elizabeth Olsen", NotificationLabel: "Swiped Right your post!"),
        
        Notification(NotificationProfileImage: UIImage(named: "Not_1")!, NotificationPostPreview: UIImage(named: "not_2")!, NotificationName: "Elizabeth Olsen", NotificationLabel: "Swiped Right your post!"),
        
        Notification(NotificationProfileImage: UIImage(named: "Not_1")!, NotificationPostPreview: UIImage(named: "not_2")!, NotificationName: "Elizabeth Olsen", NotificationLabel: "Swiped Right your post!")
        
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationReusable")
        
        
    }
}


extension NotificationsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationReusable", for: indexPath) as! NotificationCell
        
        cell.NotificationProfImg.image = notifications[indexPath.row].NotificationProfileImage
        cell.NotPostPrev.image = notifications[indexPath.row].NotificationPostPreview
        cell.NotNick.text = notifications[indexPath.row].NotificationName
        cell.NotLabel.text = notifications[indexPath.row].NotificationLabel
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, EditingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            tableView.beginUpdates()
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at:[indexPath]  , with: .fade)
            tableView.endUpdates()
        }
        
    }
    
}

