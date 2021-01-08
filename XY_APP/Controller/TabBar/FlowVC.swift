//
//  FlowVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import Firebase

class FlowVC : UITableViewController {
    var data: [FlowDataModel] = []
    
    @IBOutlet weak var barXPCircle: CircleView!
    
    override func viewDidLoad() {
        
        barXPCircle.layer.shadowRadius = 10
        barXPCircle.layer.shadowOffset = .zero
        barXPCircle.layer.shadowOpacity = 0.5
        barXPCircle.layer.shadowColor = UIColor.blue.cgColor
        barXPCircle.layer.shadowPath = UIBezierPath(rect: barXPCircle.bounds).cgPath
        barXPCircle.layer.masksToBounds = false
        barXPCircle.levelLabel.text = "4"
        barXPCircle.levelLabel.textColor = .white
        barXPCircle.backgroundColor = .clear
        barXPCircle.tintColor = .blue
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        tableView.register(UINib(nibName: ImagePostCell.nibName, bundle: nil), forCellReuseIdentifier: ImagePostCell.identifier)
        
        
        
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func xpButtonPressed() {
        
        performSegue(withIdentifier: "segueToNotifications", sender: self)
    }
    
    private func fetchData() {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
                    .order(by: "\(FirebaseKeys.PostKeys.postData).\(FirebaseKeys.PostKeys.timestamp)", descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            if let documents = snapshot?.documents {
                for doc in documents {
                    let documentData = doc.data()
                    if let postData = documentData["postData"] as? [String: Any] {
                        self.data.append(
                            PostData(
                                id: doc.documentID,
                                userId: documentData["author"] as! String,
                                timestamp: (postData["timestamp"] as! Firebase.Timestamp).dateValue(),
                                content: postData["caption"] as! String,
                                images: [postData["imageRef"] as! String]
                            ))
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier) as! ImagePostCell
        var cellViewModel = PostViewModel()
        cellViewModel.data =  data[indexPath.row] as! PostData
        cell.viewModel = cellViewModel
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15 // Return the spacing between sections
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear // Make the background color show through
        return headerView
    }
}
