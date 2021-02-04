//
//  FlowVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import Firebase
import ImagePicker


class FlowVC : UITableViewController {
    
    // MARK: - Properties
    
    var postViewModels = [PostViewModel]()
    
    @IBOutlet weak var barXPCircle: CircleView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "Black")
        
        tableView.showsVerticalScrollIndicator = false
        
        barXPCircle.setProgress(level: 0, progress: 0.0)
        barXPCircle.setupFinished()
        barXPCircle.setLevelLabelFontSize(size: 24)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(named: "Black") // This is necessary to scroll touching outside of the cell, lol.
        tableView.separatorStyle = .none
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.register(ImagePostCell.self, forCellReuseIdentifier: ImagePostCell.identifier)
        prefetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseSubscriptionManager.shared.registerXPUpdates(for: uid, ofType: .user) { [weak self] (xpModel) in
                guard let nextLevelXP = XPModel.LEVELS[.user]?[xpModel.level] else { return }
                self?.barXPCircle.setProgress(
                    level: xpModel.level,
                    progress: Float(xpModel.xp) / Float(nextLevelXP)
                )
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: uid)
        }
    }
    
    // MARK: - Obj-C Functions
    @objc func xpButtonPressed() {
        // Level up check
        FirebaseFunctionsManager.shared.checkUserLevelUp()
        //
        performSegue(withIdentifier: "segueToNotifications", sender: self)
    }
    
    // MARK: - IBActions
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done")
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
    }
    
    // MARK: - Public Functions
    
    public func insertPost(_ postData: PostViewModel) {
        guard let indexPathToInsert = tableView.indexPathsForVisibleRows?.first else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.postViewModels.insert(postData, at: indexPathToInsert.row)
            self.tableView.insertRows(at: [indexPathToInsert], with: .top)
            
            guard let newPostCell = self.tableView.cellForRow(at: indexPathToInsert) as? ImagePostCell else {
                return
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func prefetchData() {
        
        var initializingFlow = true
        FirebaseDownload.getFlowUpdates() { newPosts, error in
            if let error = error { print("Error fetching posts: \(error)") }
            print("Flow update")
            if let posts = newPosts {
                for newPost in posts {
                    if self.postViewModels.contains(where: { $0.postId == newPost.id }) { continue } else
                    {
                        if initializingFlow {
                            let postViewModel = PostViewModel(from: newPost)
                            self.postViewModels.append(postViewModel)
                        } else {
                            // Insert into visible row
                            let firstVisibleRowIndex = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
                            // Automatically updates tableview
                            DispatchQueue.main.async {
                                let postViewModel = PostViewModel(from: newPost)
                                self.postViewModels.insert(postViewModel, at: firstVisibleRowIndex.row)
                                self.tableView.insertRows(at: [firstVisibleRowIndex], with: .bottom)
                            }
                        }
                    }
                }
                if initializingFlow {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        initializingFlow = false
                    }
                }
            }
        }
    }
    
    // MARK: - TableView Overrides
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 465
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier) as! ImagePostCell
        
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear // Make the background color show through
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let postCell = cell as? ImagePostCell else {
            return
        }
        postCell.configure(with: postViewModels[indexPath.row])
    }
}

// MARK: - ImagePostCell Delegate functions

extension FlowVC : ImagePostCellDelegate {
    func imagePostCellDelegate(didTapProfilePictureForProfile profileId: String) {
        
        FirebaseDownload.getOwnerUser(forProfileId: profileId) { userId, error in
            guard let userId = userId, error == nil else {
                print("Error fetching profile with id: \(profileId)")
                print(error)
                return
            }
            
            let profileVC = ProfileViewController(userId: userId)
            profileVC.modalPresentationStyle = .popover
            
            self.present(profileVC, animated: true) { }
        }
    }
    
    func imagePostCellDelegate(reportPressed postId: String) {
        let alert = UIAlertController(title: "Report", message: "Why are you reporting this post?", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Report details"
            textfield.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        }
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action) in
            let textfield = alert.textFields![0]
            
            guard let text = textfield.text else {
                return
            }
            
            FirebaseUpload.sendReport(message: text, postId: postId)
            
            if let index = self.postViewModels.firstIndex(where: { $0.postId == postId }) {
                self.postViewModels.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell) {
        
    }
    
    func imagePostCellDelegate(willSwipeLeft cell: ImagePostCell) {
        guard let cellIndex = tableView.indexPath(for: cell),
              postViewModels.count > cellIndex.row else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            cell.alpha = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.postViewModels.remove(at: cellIndex.row)
            
            self.tableView.deleteRows(at: [cellIndex], with: .bottom)
            
            guard self.postViewModels.count > cellIndex.row else {
                return
            }
            
            self.tableView.scrollToRow(at: cellIndex, at: .middle, animated: true)
        }
    }
    
    func imagePostCellDelegate(willSwipeRight cell: ImagePostCell) {
        guard let cellIndex = tableView.indexPath(for: cell),
              postViewModels.count > cellIndex.row else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            cell.alpha = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.postViewModels.remove(at: cellIndex.row)
            
            self.tableView.deleteRows(at: [cellIndex], with: .bottom)
            
            guard self.postViewModels.count > cellIndex.row else {
                return
            }
            self.tableView.scrollToRow(at: cellIndex, at: .middle, animated: true)
        }
    }
    
    func imagePostCellDelegate(didSwipeLeft postId: String) {
        FirebaseFunctionsManager.shared.swipeLeft(postId: postId)
    }
    
    func imagePostCellDelegate(didSwipeRight postId: String) {
        FirebaseFunctionsManager.shared.swipeRight(postId: postId)
    }
}
