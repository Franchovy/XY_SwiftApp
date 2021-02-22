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
    
    var postViewModels = [NewPostViewModel]()
    
    @IBOutlet weak var barXPCircle: CircleView!
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 21)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Error fetching Flow!"
        return label
    }()
    
    /// Index of fetch, for loading posts that come from the same user
    var currentFlowIndex: Int = 0
    
    var canRefresh = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "Black")
        
        tableView.showsVerticalScrollIndicator = false
        
        barXPCircle.setProgress(level: 0, progress: 0.0)
        barXPCircle.setupFinished()
        barXPCircle.setLevelLabelFontSize(size: 24)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)
        
        view.addSubview(errorLabel)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(named: "Black") // This is necessary to scroll touching outside of the cell, lol.
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(flowRefreshed(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.register(ImagePostCell.self, forCellReuseIdentifier: ImagePostCell.identifier)
        
        getFlow()
        
        registerXPUpdates()
        
        isHeroEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.isHidden = true
        
//        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerXPUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: uid)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        errorLabel.sizeToFit()
        errorLabel.frame = CGRect(
            x: (view.width - errorLabel.width)/2,
            y: view.top + 35,
            width: errorLabel.width,
            height: errorLabel.height
        )
    }
    
    // MARK: - Obj-C Functions
    @objc func xpButtonPressed() {
        // Level up check
        FirebaseFunctionsManager.shared.checkUserLevelUp()
        //
        performSegue(withIdentifier: "segueToNotifications", sender: self)
    }
    
    @objc func flowRefreshed(_ sender: UIRefreshControl) {
        
        FlowAlgorithmManager.shared.algorithmIndex += 1
        getFlow()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
            self.refreshControl?.endRefreshing()
        }
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
    
    public func getFlow() {
        self.errorLabel.isHidden = true
                
        FlowAlgorithmManager.shared.getFlow() { posts in
            guard let posts = posts else {
                // Error fetching posts
                self.errorLabel.isHidden = false
                return
            }
            
            self.postViewModels = []
            
            for newPost in posts {
                if self.postViewModels.contains(where: { $0.id == newPost.id }) { continue } else
                {
                    let loadingViewModel = PostViewModelBuilder.build(from: newPost) { (viewModel) in
                        if let viewModel = viewModel,
                           let index = self.postViewModels.firstIndex(where: { $0.id == viewModel.id }) {
                            self.postViewModels[index] = viewModel
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    }
                    
                    self.postViewModels.append(loadingViewModel)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Private Functions
    
    private func registerXPUpdates() {
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseSubscriptionManager.shared.registerXPUpdates(for: uid, ofType: .user) { [weak self] (xpModel) in
                let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(xpModel.level, .user)
                self?.barXPCircle.setProgress(
                    level: xpModel.level,
                    progress: Float(xpModel.xp) / Float(nextLevelXP)
                )
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ImagePostCell
        cell.setHeroIDs(forPost: "post", forCaption: "caption", forImage: "image")
        let vc = PostViewController(with: postViewModels[indexPath.row])
        
        vc.isHeroEnabled = true
        vc.modalPresentationStyle = .fullScreen
        vc.onDismiss = { cell.setHeroIDs(forPost: "", forCaption: "", forImage: "") }
        
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - ImagePostCell Delegate functions

extension FlowVC : ImagePostCellDelegate {
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
            
            if let index = self.postViewModels.firstIndex(where: { $0.id == postId }) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            
        }
    }
    
    func imagePostCellDelegate(didSwipeLeft cell: ImagePostCell) {
        guard let postId = cell.viewModel?.postId else {
            return
        }
        FirebaseFunctionsManager.shared.swipeLeft(postId: postId)
    }
    
    func imagePostCellDelegate(didSwipeRight cell: ImagePostCell) {
        guard let cellIndex = tableView.indexPath(for: cell),
              postViewModels.count > cellIndex.row else {
            return
        }
        
        self.postViewModels.remove(at: cellIndex.row)
        
        self.tableView.deleteRows(at: [cellIndex], with: .bottom)
        
        guard self.postViewModels.count > cellIndex.row else {
            return
        }
        self.tableView.scrollToRow(at: cellIndex, at: .middle, animated: true)
        
        guard let postId = cell.viewModel?.postId else {
            return
        }
        
        FirebaseFunctionsManager.shared.swipeRight(postId: postId)
    }
}
