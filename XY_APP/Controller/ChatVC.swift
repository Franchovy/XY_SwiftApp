//
//  ChatVC.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import Foundation
import UIKit
import Firebase

class ChatVC : UIViewController {
    
    static let identifier = "ChatVC"
    
    let db = FirestoreReferenceManager.root
    
    var userinfo: [ChatUserInfo] = [
        
        ChatUserInfo(ChatProfileImage: UIImage(named: "eo_profimg")!, ChatNameInfo: "Elizabeth Olsen")
    ]
    
    var messages: [MessageModel] = []
    
    
    @IBOutlet weak var chatTableView: UITableView!
 
    @IBOutlet weak var chatTextPlaceholder: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        self.chatTableView.keyboardDismissMode = .interactive
        self.hideKeyboardWhenTappedAround()
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        chatTextPlaceholder.backgroundColor = .clear
        chatTextPlaceholder.layer.borderWidth = 2
        chatTextPlaceholder.layer.cornerRadius = 15
        chatTextPlaceholder.layer.borderColor = UIColor.white.cgColor
        
        chatTableView.dataSource = self
        
        chatTableView.register(UINib(nibName: "UserInfoChat", bundle: nil), forCellReuseIdentifier: "senderDataReusable")
        
        chatTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageReusable")
        
        loadMessages()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBOutlet weak var typingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var typingView: UIView!
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardReponder = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let height = keyboardReponder.cgRectValue.height
            
            
            typingViewHeightConstraint.constant += height
            
            typingView.layoutIfNeeded()
            
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardReponder = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let height = keyboardReponder.cgRectValue.height
            
            
            typingViewHeightConstraint.constant -= height
            
            typingView.layoutIfNeeded()
            
            
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        typingViewHeightConstraint.constant = view.safeAreaInsets.bottom
        typingView.layoutIfNeeded()
        
    }
    
    func loadMessages() {
        
        db.collection(FirebaseKeys.CollectionPath.conversations)
            .order(by: FirebaseKeys.CollectionPath.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                
                self.messages = []
                
                if error != nil {
                    print("problems :/")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageSender = data[FirebaseKeys.CollectionPath.senderField] as? String, let messageBody = data[FirebaseKeys.CollectionPath.bodyField] as? String, let timeLabel = data[FirebaseKeys.CollectionPath.dateField] as? TimeInterval {
                                let newMessage = MessageModel(senderId: messageSender, message: messageBody, timeLabel: Date.init(timeIntervalSinceNow: timeLabel))
                                self.messages.append(newMessage)
                                DispatchQueue.main.async {
                                    self.chatTableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                                
                            } else {
                                //fatalError()
                            }
                        }
                    }
                }
            }
    }
    
    func getStringForTimestamp(timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return date.description
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = chatTextPlaceholder.text, let messageSender = Firebase.Auth.auth().currentUser?.email {
            db.collection(FirebaseKeys.CollectionPath.conversations).addDocument(data: [FirebaseKeys.CollectionPath.senderField : messageSender, FirebaseKeys.CollectionPath.bodyField : messageBody, FirebaseKeys.CollectionPath.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print(" There was an issue like in my code lol, \(e)")
                } else {
                    print("Succesfull yeah ")
                    DispatchQueue.main.async {
                        self.chatTextPlaceholder.text = ""
                    }
                    
                }
            }
        }
    }
}

extension ChatVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "senderDataReusable", for: indexPath) as!
                UserInfoChat
            cell.chatProfImg.image = userinfo[indexPath.row].ChatProfileImage
            cell.chatNickString.text = userinfo[indexPath.row].ChatNameInfo
            return cell
        
        } else {
            
            print("Index Path: \(indexPath)")
            print("Row: \(indexPath.row)")
            print("Message data size: \(messages.count)")
            print("Anything in message? \(String(describing: messages[indexPath.row - 1]))")
            
            let message = messages[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageReusable", for: indexPath) as!
                MessageCell
            cell.timeLabelMessage.text = messages[indexPath.row - 1].timeLabel.description
            
            // message from the current user
            
            if message.senderId == Auth.auth().currentUser?.email {
                cell.pinkMessageBubble.isHidden = true
                cell.messageBubble.isHidden = false
                
                cell.textLabelMessage.text = message.message
                cell.messageBubble.sizeToFit()
                
            }
            
            // message from another sender
            
            else {
                cell.pinkMessageBubble.isHidden = false
                cell.messageBubble.isHidden = true
                
                cell.pinkTextLabelMessage.text = message.message
                cell.pinkMessageBubble.sizeToFit()
                
            }
            
            
            
            return cell
        }
        
    }
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
