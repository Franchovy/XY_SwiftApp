//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit
import Firebase
import FirebaseStorage

class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var ringBar: CircleView!
    
    @IBOutlet weak var tableView: FlowTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ringBar.layer.shadowRadius = 10
        ringBar.layer.shadowOffset = .zero
        ringBar.layer.shadowOpacity = 0.5
        ringBar.layer.shadowColor = UIColor.blue.cgColor
        ringBar.layer.shadowPath = UIBezierPath(rect: ringBar.bounds).cgPath
        ringBar.layer.masksToBounds = false
        ringBar.levelLabel.text = "4"
        ringBar.levelLabel.textColor = .white
        ringBar.backgroundColor = .clear
        ringBar.tintColor = .blue
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.parentViewController = self
        
        // Get posts from backend
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).getDocuments(source: .default) { documentSnapshots, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let documentSnapshots = documentSnapshots {
                for doc in documentSnapshots.documents {
                    let data = doc.data()
                    let author = data["author"] as! String
                    
                    let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(author)
                    userDoc.getDocument { userdata, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        
                        if let userdata = userdata {
                            let username = userdata["xyname"] as! String
                            
                            print("Post data: \(data["postData"])")
                            
                            let postData = data["postData"] as! NSMutableDictionary
                            
                            let caption = postData["caption"] as! String
                            let imageRef = postData["imageRef"] as! String
                            let timestamp = postData["timestamp"] as! Firebase.Timestamp
                            
                            print("Got post: Written by \(author): content: \(caption), imageId: \(imageRef), posted at: \(timestamp)")
                            
                            self.tableView.posts.append(PostData(id: doc.documentID, username: username, timestamp: Date(timeIntervalSince1970: TimeInterval(timestamp.seconds)), content: caption, images: [imageRef]))
                            
                            ///
                            // Get function from store
                            let storage = Storage.storage()
                            let pathReference = storage.reference(withPath: imageRef)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        // Set posts inside tableview
    
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func xpButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        //self.navigationController?.pushViewController(vc, animated: true)
        self.show(vc, sender: self)
    }
}

