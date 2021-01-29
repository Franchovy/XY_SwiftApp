//
//  NotificationsVC.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationViewModel]()
    
    var notificationsListener : ListenerRegistration?
    
    let queryLimit: Int = 30
    var lastFetchedElement: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        tableView.backgroundColor = .clear
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        
        // Create subscription to notifications
        subscribeToNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // deactivate listener.
        notificationsListener?.remove()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(
            x: view.safeAreaInsets.top,
            y: 0,
            width: view.width,
            height: view.height
        )
    }
    
    private func subscribeToNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var initializing = true
        
        let notificationsDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(uid).collection(FirebaseKeys.NotificationKeys.notificationsCollection).order(by: FirebaseKeys.NotificationKeys.notifications.timestamp, descending: true)
        
        notificationsListener = notificationsDocument.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print(error)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if initializing {
                // Append post
                for notificationDocument in querySnapshot.documents {
                    self?.lastFetchedElement = notificationDocument
                    
                    let data = notificationDocument.data()
                    
                    let notificationModel = Notification(data, id: notificationDocument.documentID)
                    var notificationViewModel = NotificationViewModel(from: notificationModel)
                    notificationViewModel.delegate = strongSelf
                    
                    strongSelf.notifications.append(notificationViewModel)
                    
                }
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                initializing = false

            } else {
                for documentChanges in querySnapshot.documentChanges {
                    if documentChanges.type == .added {
                        let document = documentChanges.document
                        let data = document.data()

                        let notificationModel = Notification(data, id: document.documentID)
                        var notificationViewModel = NotificationViewModel(from: notificationModel)
                        notificationViewModel.delegate = strongSelf

                        strongSelf.notifications.insert(notificationViewModel, at: 0)

                        strongSelf.tableView.insertRows(
                            at: [IndexPath(row: 0, section: 0)],
                            with: .top
                        )
                    }
                }
            }
        }
    }
}


extension NotificationsVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as! NotificationCell
        
        viewModel.fetch(index: indexPath.row)
        cell.configure(with: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, EditingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            print(indexPath.row)
            print(notifications.count)
            
            guard notifications.count > indexPath.row else {
                return
            }
            
            tableView.beginUpdates()
            
            let notificationToDelete = notifications[indexPath.row]
            
            // Remove notification from backend
            FirebaseUpload.deleteNotification(notificationId: notificationToDelete.notificationId)
            
            notifications.remove(at: indexPath.row)
            
            tableView.deleteRows(at:[indexPath]  , with: .fade)
            
            tableView.endUpdates()
        }
    }
    
}

extension NotificationsVC : NotificationViewModelDelegate {
    func didFetchProfileData(index: Int, profile: ProfileModel) {
        
        guard let cell = tableView.cellForRow(
                at: IndexPath(row: index, section: 0)
        ) as? NotificationCell else {
            return
        }
        cell.nicknameLabel.text = profile.nickname
        cell.layoutSubviews()
    }
    
    func didFetchPostForHandler(index: Int, post: PostModel) {
        // Open post vc segue
    }
    
    func didFetchDisplayImage(index: Int, image: UIImage) {
        print("Fetched profile image: \(image)")
        guard let cell = tableView.cellForRow(
                at: IndexPath(row: index, section: 0)
        ) as? NotificationCell else {
            return
        }
        cell.profileImage.image = image
        cell.setNeedsLayout()
    }
    
    func didFetchPreviewImage(index: Int, image: UIImage) {
        print("Fetched preview image: \(image)")
        guard let cell = tableView.cellForRow(
                at: IndexPath(row: index, section: 0)
        ) as? NotificationCell else {
            return
        }
        cell.postImage.image = image
        cell.setNeedsLayout()
    }
    
    func didFetchText(index: Int, text: String) {
        print("Fetched text: \(text)")
    }
    
    
}
