//
//  NotificationsVC.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit
import FirebaseAuth

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationViewModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationReusable")
        
        // Create subscription to notifications
        subscribeToNotifications()
    }
    
    private func subscribeToNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let notificationsDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(uid).collection(FirebaseKeys.NotificationKeys.notificationsCollection)
        
        notificationsDocument.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print(error)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.notifications = []
            
            for notificationDocument in querySnapshot.documents {
                let data = notificationDocument.data()
                print("Fetched notification: \(data)")
                
                let notificationModel = Notification(data)
                var notificationViewModel = NotificationViewModel(from: notificationModel)
                notificationViewModel.delegate = strongSelf
                
                notificationViewModel.fetch(index: strongSelf.notifications.count)
                strongSelf.notifications.append(notificationViewModel)
            }
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
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
            
            // Remove notification from backend
            
            
            tableView.deleteRows(at:[indexPath]  , with: .fade)
            tableView.endUpdates()
        }
    }
    
}

extension NotificationsVC : NotificationViewModelDelegate {
    func didFetchPostForHandler(index: Int, post: PostModel) {
        // Open post vc
        
    }
    
    func didFetchDisplayImage(index: Int, image: UIImage) {
        guard let cell = tableView.cellForRow(
                at: IndexPath(row: index, section: 0)
        ) as? NotificationCell else {
            return
        }
        cell.NotificationProfImg.image = image
    }
    
    func didFetchPreviewImage(index: Int, image: UIImage) {
        guard let cell = tableView.cellForRow(
                at: IndexPath(row: index, section: 0)
        ) as? NotificationCell else {
            return
        }
        cell.NotPostPrev.image = image
    }
    
    func didFetchText(index: Int, text: String) {
        
    }
    
    
}
