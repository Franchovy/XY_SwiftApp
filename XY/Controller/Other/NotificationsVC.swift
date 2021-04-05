//
//  NotificationsVC.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit
import Firebase

class NotificationsVC: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    var notifications = [_NotificationViewModel]()
    
    var notificationsListener : ListenerRegistration?
    
    let queryLimit: Int = 30
    var lastFetchedElement: DocumentSnapshot?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(named: "Black")
        view.addSubview(tableView)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        hidesBottomBarWhenPushed = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYNavbarLogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllNotificationsPressed))
        
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
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.height
        )
    }
    
    private func subscribeToNotifications() {
        guard let userId = AuthManager.shared.userId else { return }
        
        var initializing = true
        
        let notificationsDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(userId).collection(FirebaseKeys.NotificationKeys.notificationsCollection).order(by: FirebaseKeys.NotificationKeys.notifications.timestamp, descending: true)
        
        notificationsListener = notificationsDocument.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print(error)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if initializing {
                strongSelf.notifications = []
                print("Initializing notifications")
                // Append post
                for notificationDocument in querySnapshot.documents {
                    self?.lastFetchedElement = notificationDocument
                    
                    let data = notificationDocument.data()
                    
                    let notificationModel = _Notification(data, id: notificationDocument.documentID)
                    var notificationViewModel = _NotificationViewModel(from: notificationModel)
                    notificationViewModel.delegate = strongSelf
                    
                    print("Appending notification of type: \(notificationModel.objectType)")
                    strongSelf.notifications.append(notificationViewModel)
                    
                }
                DispatchQueue.main.async {
                    print("Reloading notifications")
                    strongSelf.tableView.reloadData()
                }
                initializing = false

            } else {
                print("Updating notifications")
                for documentChanges in querySnapshot.documentChanges {
                    if documentChanges.type == .added {
                        print("Inserting new notification")
                        let document = documentChanges.document
                        let data = document.data()

                        let notificationModel = _Notification(data, id: document.documentID)
                        var notificationViewModel = _NotificationViewModel(from: notificationModel)
                        notificationViewModel.delegate = strongSelf

                        strongSelf.notifications.insert(notificationViewModel, at: 0)

                        strongSelf.tableView.insertRows(
                            at: [IndexPath(row: 0, section: 0)],
                            with: .top
                        )
                    } else if documentChanges.type == .removed {
                        print("Deleting notification")
                        
                        let document = documentChanges.document
                        let data = document.data()

                        let numberOfNotificationsCheck = strongSelf.notifications.count
                        strongSelf.notifications.removeAll { $0.notificationId == document.documentID }

                        let numberOfNotificationsCheckAfterRemove = strongSelf.notifications.count
                        
                        if numberOfNotificationsCheck - 1 == numberOfNotificationsCheckAfterRemove {
                            strongSelf.tableView.deleteRows(
                                at: [IndexPath(row: 0, section: 0)],
                                with: .left
                            )
                        } else {
                            print("Error updating for removed notification!")
                        }
                    }
                }
            }
        }
    }
    
    @objc private func deleteAllNotificationsPressed() {
        FirebaseUpload.deleteAllNotifications()
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
        cell.delegate = self
        
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

extension NotificationsVC : NotificationCellDelegate {
    func pushPostViewController(_ vc: PostViewController) {
        self.navigationController?.isHeroEnabled = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationsVC : NotificationViewModelDelegate {
    
    func didOpenProfile(profile: ProfileModel) {
        FirebaseDownload.getOwnerUser(forProfileId: profile.profileId) { (userId, error) in
            guard let userId = userId, error == nil else {
                print(error ?? "Error loading profile: \(profile)")
                return
            }
            let profileVC = NewProfileViewController(userId: userId)
            self.navigationController?.pushViewController(profileVC, animated: true)
            
        }
    }
    
    func didOpenPost(post: PostModel) {
        // Open Post VC
    }
    
    func didFetchProfileData(index: Int, profile: ProfileModel) {
        guard let containsCell = tableView.indexPathsForVisibleRows?.contains(IndexPath.init(row: index, section: 0)),
              containsCell,
              let cell = tableView.visibleCells.filter({ (cell) -> Bool in
                if let notificationCell = cell as? NotificationCell {
                    return notificationCell.viewModel === notifications[index]
                } else {
                    return false
                }
              }).first as? NotificationCell else {
            return
        }
        
        cell.nicknameLabel.text = profile.nickname
        cell.layoutSubviews()
    }
    
    func didFetchPostForHandler(index: Int, post: PostModel) {
        // Open post vc segue
        guard let cell = tableView.visibleCells.filter({ (cell) -> Bool in
                if let loadedCell = cell as? NotificationCell {
                    return loadedCell.viewModel === notifications[index]
                } else {
                    return false
                }
        }).first as? NotificationCell else {
            return
        }
        
        cell.loadPostData(postModel: post)
    }
    
    func didFetchDisplayImage(index: Int, image: UIImage) {
        guard let containsCell = tableView.indexPathsForVisibleRows?.contains(IndexPath.init(row: index, section: 0)),
              containsCell,
              let cell = tableView.visibleCells.filter({ (cell) -> Bool in
                if let notificationCell = cell as? NotificationCell {
                    return notificationCell.viewModel === notifications[index]
                } else {
                    return false
                }
              }).first as? NotificationCell else {
            return
        }
        
        cell.profileImage.setBackgroundImage(image, for: .normal)
        cell.setNeedsLayout()
    }
    
    func didFetchPreviewImage(index: Int, image: UIImage) {
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
