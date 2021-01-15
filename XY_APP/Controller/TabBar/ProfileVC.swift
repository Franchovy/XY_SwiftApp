//
//  ProfileVC.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth

class ProfileVC : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var topCell: ProfileCell!
    var bottomCell: ProfileFlowTableViewCell!
    
    var ownerId: String = Auth.auth().currentUser!.uid
 
    var modalEscapable: Bool = false
    
    var panGestureInAction: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: ProfileCell.identifier)
        tableView.register(UINib(nibName: "ProfileFlowTableViewCell", bundle: nil), forCellReuseIdentifier: "profileBottomReusable")

        var escapeModalGesture = UIPanGestureRecognizer(target: self, action: #selector(escapeModal(panGestureRecognizer:)))
        escapeModalGesture.isEnabled = modalEscapable
        escapeModalGesture.delegate = self
        tableView.addGestureRecognizer(escapeModalGesture)
        
//        var scrollGesture = UIPanGestureRecognizer(target: self, action: #selector(scrolling(panGestureRecognizer:)))
//        tableView.addGestureRecognizer(scrollGesture)
        
        tableView.isUserInteractionEnabled = true
        
        
    }
    
    var escapeModalGestureOngoing = false
    
    @objc func escapeModal(panGestureRecognizer: UIPanGestureRecognizer) {
        let touchPoint = panGestureRecognizer.location(in: view?.window)
        var initialTouchPoint = CGPoint.zero
        
        if escapeModalGestureOngoing {
            switch panGestureRecognizer.state {
            case .began:
                initialTouchPoint = touchPoint
            case .changed:
                if touchPoint.y > initialTouchPoint.y {
                    view.frame.origin.y = touchPoint.y - initialTouchPoint.y
                }
            case .ended, .cancelled:
                panGestureInAction = false
                
                if touchPoint.y - initialTouchPoint.y > 200 {
                    dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: self.view.frame.size.width,
                                                 height: self.view.frame.size.height)
                    })
                }
            case .failed, .possible:
                break
            }
        }
    }
    
    func logoutSegue() {
        // Log out
        if let vc1 = self.tabBarController {
            if let vc2 = vc1.navigationController {
                vc2.popToRootViewController(animated: true)
            }
        }
    }
    
    
    func segueToChat() {
        //Segue to chat viewcontroller
        print("Segue to chat!")
        
    }
    
    func chatSegue() {
        
        if ownerId == Auth.auth().currentUser!.uid {
            performSegue(withIdentifier: "segueToChat", sender: self)
        } else {
            // Open message VC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: ChatVC.identifier) as! ChatVC
            
            
            FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
                .whereField(FirebaseKeys.ConversationKeys.members, arrayContains: Auth.auth().currentUser!.uid)
                .getDocuments() { snapshotDocuments, error in
                if let error = error { print("Error fetching conversations!") }
                    
                if let snapshotDocuments = snapshotDocuments {
                    if !snapshotDocuments.isEmpty {
                        // Check this user's conversations for one with the other user
                        for document in snapshotDocuments.documents {
                            let conversationMembers = document.get(FirebaseKeys.ConversationKeys.members) as! [String]
                            if conversationMembers.contains(self.ownerId) {
                                // Set conversation id
                                chatVC.conversationId = document.documentID
                            }
                        }
                    }
                    
                    if chatVC.conversationId == nil {
                        chatVC.otherMemberId = self.ownerId
                    }
                    
                    self.present(chatVC, animated: true, completion: {})
                }
            }
        }
    }
    
    func settingsSegue() {
        performSegue(withIdentifier: "segueToSettings", sender: self)
    }
}

extension ProfileVC : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Fade background of cover picture on scroll down
                
        let scrollPositionProportionToWidth = max(0, 1 - (tableView.contentOffset.y / (topCell.coverImage.frame.height - topCell.profileCard.frame.height)))
        topCell.coverImage.layer.opacity = Float(scrollPositionProportionToWidth)
        topCell.backgroundColor = .black
    }
}

extension ProfileVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
            
            cell.viewModel = ProfileViewModel(userId: ownerId)
            // Add "Tap anywhere" escape function from keyboard focus
            let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: cell, action: #selector(cell.tappedAnywhere(tapGestureRecognizer:)))
            view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
            
            cell.imagePickerDelegate = self
            
            cell.onKeyboardDismiss = { self.dismissKeyboard() }
            cell.isOwnProfile = ownerId == Auth.auth().currentUser!.uid
            cell.onChatButtonPressed = chatSegue
            cell.onSettingsButtonPressed = settingsSegue
            
            
            topCell = cell
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileBottomReusable", for: indexPath) as! ProfileFlowTableViewCell
            cell.ownerId = ownerId
            return cell
        }
    }
}
    

extension ProfileVC : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            // Detect escape gesture
            if panGestureRecognizer.location(in: tableView.visibleCells[0]).y < 400 &&
                    panGestureRecognizer.velocity(in: tableView.visibleCells[0]).y > 150 {
                escapeModalGestureOngoing = true
            } else {
                escapeModalGestureOngoing = false
            }
            
            return escapeModalGestureOngoing
        } else {
            return true
        }
    }
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//            return false
//            return panGestureRecognizer.velocity(in: UpProfTableView).y > 500 || panGestureRecognizer.location(in: UpProfTableView).y < 250
//        } else {
//            return false
//        }
//    }
}
    
    //extension ProfileVC : UITableViewDelegate {
        
        //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //   print(indexPath.row)
            
      //  }
        
  //  }
    
extension ProfileVC : XYImagePickerDelegate {
    func presentImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }

    func onImageUploadSucceed() {
        
    }
}

