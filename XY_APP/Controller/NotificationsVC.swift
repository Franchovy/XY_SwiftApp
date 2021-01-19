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
    
    var notifications: [NotificationViewModel] = [
        
        NotificationViewModel(displayImage: UIImage(named: "Not_1")!, previewImage: UIImage(named: "not_2")!, title: "Elizabeth Olsen", text: "Swiped Right your post!", onSelect: nil)
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationReusable")
        
        FirebaseDownload.getNotifications(since: Date(), completion: { [weak self] notifications, error in
            // Create viewmodels from notifications
            guard let notifications = notifications, error == nil else {
                print("Error fetching notifications: \(error)")
                return
            }
            
            for model in notifications {
                // Fetch data for notification
                // profile, profile pic, post, post pic
                
                let notificationVM = NotificationViewModel(
                    displayImage: nil,
                    previewImage: nil,
                    title: model.type.title,
                    text: {
                        switch model.type {
                        case .swipeRight:
                            return "Swiped right on your post!"
                        case .swipeLeft:
                            return "Swiped left on your post!"
                        case .levelUp:
                            return "Leveled up!"
                        }
                    }(),
                    onSelect: {} )
                
                self?.notifications.append(notificationVM)
                    
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
}


extension NotificationsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationReusable", for: indexPath) as! NotificationCell
        
        cell.configure(with: model)
        
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

