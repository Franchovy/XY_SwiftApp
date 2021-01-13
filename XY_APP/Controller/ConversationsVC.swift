//
//  MessagesViewController.swift
//  XY_APP
//
//  Created by Simone on 10/12/2020.
//

import Foundation
import UIKit
import Firebase


class ConversationsVC: UIViewController, ConversationViewModelDelegate {
    
    func onFetchedPreviewMessage(_ message: String, indexRow: Int) {
        viewModels[indexRow].conversation.messagePreview = message
        let cell = conversationsTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as! ConversationCell
        cell.convMsgPrev.text = message
    }
    
    func onFetchedProfileData(_ profile: ProfileModel, indexRow: Int) {
        viewModels[indexRow].conversation.senderName = profile.nickname
        let cell = conversationsTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as! ConversationCell
        cell.convSenderNick.text = profile.nickname
    }
    
    func onFetchedProfileImage(_ image: UIImage, indexRow: Int) {
        viewModels[indexRow].conversation.senderImage = image
        let cell = conversationsTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as! ConversationCell
        cell.convProfImg.image = image
    }
    
    var viewModels: [ConversationViewModel] = [] {
        didSet {
            for viewModel in viewModels {
                viewModel.delegate = self
            }
        }
    }
    
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
                
                for conversationDocument in snapshotDocuments.documents {
                    let viewModel = ConversationViewModel(conversationId: conversationDocument.documentID, indexRow: self.viewModels.count)
                    
                    self.viewModels.append(viewModel)
                    viewModel.fetch() {
                        if snapshotDocuments.count == self.viewModels.count {
                            self.conversationsTableView.reloadData()
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
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationReusableCell", for: indexPath) as! ConversationCell
        
        let conversationPreview = viewModels[indexPath.row].conversation
        
        cell.convProfImg.image = conversationPreview.senderImage
        cell.convSenderNick.text = conversationPreview.senderName
        cell.convMsgPrev.text = conversationPreview.messagePreview
        cell.convTimePrev.text = conversationPreview.latestMessageTimestamp?.description ?? ""
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
        
        vc.messages = viewModels[indexPath.row].messages
        vc.conversationId = viewModels[indexPath.row].id
        
        present(vc, animated: true) {
            vc.onUserInfoFetched(image: self.viewModels[indexPath.row].conversation.senderImage!, name: self.viewModels[indexPath.row].conversation.senderName!)
        }
    }
    
    
}
