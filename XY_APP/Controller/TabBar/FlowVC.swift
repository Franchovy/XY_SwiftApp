//
//  FlowVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import Firebase
import ImagePicker

class FlowVC : UITableViewController, ImagePickerDelegate, XPViewModelDelegate {    
    func setProgress(level: Int, progress: Float) {
        barXPCircle.levelLabel.text = String(describing: level)
        barXPCircle.progressBarCircle.progress = CGFloat(progress)
        barXPCircle.setupFinished()
    }
    
    func onProgress(level: Int, progress: Float) {
        barXPCircle.levelLabel.text = String(describing: level)
        barXPCircle.progressBarCircle.progress = CGFloat(progress)
    }
    
    var data: [FlowDataModel] = []
    
    @IBOutlet weak var barXPCircle: CircleView!
    
    override func viewDidLoad() {
        
        barXPCircle.viewModel = XPViewModel(type: .user)
        barXPCircle.viewModel.delegate = self
        barXPCircle.viewModel.subscribeToFirebase(documentId: Auth.auth().currentUser!.uid)
        
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
        tableView.reloadData()
    }
    
    // MARK: - GESTURE RECOGNIZERS
    
    @objc func xpButtonPressed() {
        
        performSegue(withIdentifier: "segueToNotifications", sender: self)
    }
    
    // MARK: - IBActions
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
       
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 3
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
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
        
        FirebaseDownload.getFlow() { posts, error in
            if let error = error { print("Error fetching posts: \(error)") }
            
            if let posts = posts {
                self.data.append(contentsOf: posts)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                DispatchQueue.global(qos: .background).async {
                    FirebaseDownload.getFlowUpdates() { posts, error in
                        if let error = error { print("Error fetching posts: \(error)") }
                        print("Flow update")
                        if let posts = posts {
                            for newPost in posts {
                                
                                if self.data.contains(where: { flowDataModel in
                                    if let postData = flowDataModel as? PostData {
                                        return postData.id == newPost.id
                                    } else { return true }
                                }) {
                                    print("Already contains this post")
                                    continue
                                } else {
                                    print("Inserting post")
                                    let lastVisibleRowIndex = self.tableView.indexPathsForVisibleRows?.last ?? IndexPath(row: 0, section: 0)
                                    
                                    self.data.insert(newPost, at: lastVisibleRowIndex.row)
                                    
                                    self.tableView.insertRows(at: [lastVisibleRowIndex], with: .bottom)
                                }
                            }
                        }
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
        cellViewModel.data =  data[indexPath.row] as! PostData
        cell.viewModel = cellViewModel
        cell.parentFlow = self
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
