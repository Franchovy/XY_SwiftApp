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
    
    var data: [FlowDataModel] = []
    
    @IBOutlet weak var barXPCircle: CircleView!
    
    override func viewDidLoad() {
        
        barXPCircle.setProgress(level: 1, progress: 0.0)
        barXPCircle.setupFinished()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(white: 0.0, alpha: 0.01) // This is necessary to scroll touching outside of the cell, lol.
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.register(UINib(nibName: ImagePostCell.nibName, bundle: nil), forCellReuseIdentifier: ImagePostCell.identifier)
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
    
    // MARK: - GESTURE RECOGNIZERS
    
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
    
    private func prefetchData() {
        
        var initializingFlow = true
        FirebaseDownload.getFlowUpdates() { newPosts, error in
            if let error = error { print("Error fetching posts: \(error)") }
            print("Flow update")
            if let posts = newPosts {
                for newPost in posts {
                    
                    if self.data.contains(where: { flowDataModel in
                        if let postData = flowDataModel as? PostModel {
                            return postData.id == newPost.id
                        } else { return true }
                    }) {
                        continue
                    } else {
                        
                        if initializingFlow {
                            self.data.append(newPost)
                        } else {
                            // Insert into visible row
                            let firstVisibleRowIndex = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
                            self.data.insert(newPost, at: firstVisibleRowIndex.row)
                            // Automatically updates tableview
                            DispatchQueue.main.async {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier) as! ImagePostCell
        var cellViewModel = PostViewModel()
        cellViewModel.data =  data[indexPath.row] as! PostModel
        cell.viewModel = cellViewModel
        cell.delegate = self
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

extension FlowVC : ImagePostCellDelegate {
    func imagePostCellDelegate(didTapProfilePictureFor cell: ImagePostCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        
        profileVC.profileId = cell.viewModel.profileId
        profileVC.ownerId = cell.viewModel.data!.userId
        
        
        profileVC.modalEscapable = true
        present(profileVC, animated: true) { }
    }
    
    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell) {
        
    }
}
