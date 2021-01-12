//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit
import Firebase


class ConversationsVC: UIViewController {
    
    
    var conversations: [ConversationPreview] = []
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        conversationsTableView.delegate = self
        
        conversationsTableView.layer.cornerRadius = 15
        conversationsTableView.dataSource = self
        conversationsTableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "conversationReusableCell")
        
        fetchConversations()
        
    }
    
    func fetchConversations() {
        // Get conversations for this user
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .whereField(FirebaseKeys.ConversationKeys.members, arrayContains: Auth.auth().currentUser!.uid)
            .getDocuments() { snapshotDocuments, error in
            if let error = error { print("Error fetching conversations!") }
            
            if let snapshotDocuments = snapshotDocuments {
                for document in snapshotDocuments.documents {
                    let conversationData = document.data()
                    
                    let conversationMemberIds = conversationData[FirebaseKeys.ConversationKeys.members] as! [String]
                    let otherMemberId = conversationMemberIds.drop(while: { $0.isEqual(Auth.auth().currentUser!.uid) } ).first!
                    
                    let otherMemberDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(otherMemberId)
                    otherMemberDocument.getDocument() { snapshot, error in
                        if let error = error { print("Error fetching other member id!") }
                        
                        if let snapshot = snapshot, let otherMemberData = snapshot.data() {
                            
                            let otherMemberName = otherMemberData[FirebaseKeys.UserKeys.xyname] as! String
                            
                            
                            self.conversations.append(ConversationPreview(
                                                        timestamp: (conversationData[FirebaseKeys.ConversationKeys.timestamp] as! Firebase.Timestamp).dateValue(),
                                conversationId: document.documentID,
                                senderId: snapshot.documentID,
                                senderImage: UIImage(named: "profile")!,
                                senderName: otherMemberName,
                                messagePreview: "",
                                mostRecentMessageTimestamp: Date()))
                            
                            if self.conversations.count == snapshotDocuments.count {
                                self.conversationsTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }
}


extension ConversationsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationReusableCell", for: indexPath) as! ConversationCell
        cell.convProfImg.image = conversations[indexPath.row].senderImage
        cell.convSenderNick.text = conversations[indexPath.row].senderName
        cell.convMsgPrev.text = conversations[indexPath.row].messagePreview
        cell.convTimePrev.text = conversations[indexPath.row].mostRecentMessageTimestamp.description
        return cell
        
    }
}

extension ConversationsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Conversation messages data
        //TODO
        let cell = tableView.cellForRow(at: indexPath) as! ConversationCell
        let userId = cell.convSenderNick
        
        // Segue to chat
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: ChatVC.identifier) as! ChatVC
        present(vc, animated: true) {
            print("Loading data for chat: \(userId)")
        }
    }
    
    
}
