//
//  PostViewController.swift
//  XY
//
//  Created by Maxime Franchot on 17/02/2021.
//

import UIKit
import Hero

class PostViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PostHeaderView.self, forHeaderFooterViewReuseIdentifier: PostHeaderView.identifier)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 410
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "Black")
        return tableView
    }()
    
    private let typeView = TypeView()
    
    var onDismiss: (() -> Void)?
    
    var postViewModel: NewPostViewModel?
    
    var commentViewModels = [CommentViewModel]()
    
    var postHeroID: String?
    var captionHeroID: String?
    var imageHeroID: String?
    
    var tappedAnywhereGesture: UITapGestureRecognizer?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        navigationItem.title = "Comments"
        
        typeView.delegate = self
        
        tappedAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tappedAnywhereGesture!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        onDismiss?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        typeView.frame = CGRect(
            x: 0,
            y: view.height - 60 - view.safeAreaInsets.bottom,
            width: view.width,
            height: 60
        )
        
        tableView.frame = view.bounds.inset(
            by: UIEdgeInsets(
                top: view.safeAreaInsets.top + 5,
                left: 0,
                bottom: view.height - typeView.top,
                right: 0
            )
        )
    }
    
    public func configure(with viewModel: NewPostViewModel) {
        postViewModel = viewModel
        
        let captionCommentViewModel = CommentViewModel(
            profileImage: viewModel.profileImage,
            text: viewModel.content,
            nickname: viewModel.nickname,
            timestamp: viewModel.timestamp,
            isLeft: true
        )
        
        commentViewModels.insert(captionCommentViewModel, at: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(tableView)
        view.addSubview(typeView)
        
        tableView.reloadData()
        
        // Fetch comments
        guard let postId = postViewModel?.id else {
            return
        }
        PostManager.shared.getComments(for: postId) { (result) in
            switch result {
            case .success(let commentModels):
                for commentModel in commentModels {
                    PostManager.shared.buildComment(from: commentModel, ownId: viewModel.userId) { (commentViewModel) in
                        if let commentViewModel = commentViewModel {

                            self.commentViewModels.insert(commentViewModel, at: 1)
                            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
                        }
                    }
                }
                
            case .failure(let error):
                print("Error fetching comments for post: \(error)")
            }
        }
    }
    
    public func setHeroIDs(forPost postID: String, forCaption captionID: String, forImage imageID: String) {
        if let caption = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CommentTableViewCell {
            caption.setHeroIDs(forCaption: captionID, forImage: imageID)
        }
        if let post = tableView.headerView(forSection: 0) as? PostHeaderView {
            post.setHeroID(id: postID)
        }
        
        postHeroID = postID
        captionHeroID = captionID
        imageHeroID = imageID
    }
    
    @objc private func closeButtonPressed() {
        dismiss(animated: true, completion: { self.onDismiss?() })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        typeView.frame.origin.y -= typeView.top - keyboardSize.height - (tabBarController?.tabBar.height ?? 49) - 25
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.contentInset = .zero
        typeView.frame.origin.y = view.height - 60
    }
    
    @objc func tappedAnywhere() {
        typeView.resignFirstResponder()
    }
}

extension PostViewController : TypeViewDelegate {
    func sendButtonPressed(text: String) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        // Upload comment
        PostManager.shared.uploadComment(forPost: postViewModel!.id, comment: text) { (result) in
            switch result {
            case .success(let comment):
                PostManager.shared.buildComment(from: comment, ownId: userId) { (commentViewModel) in
                    if let commentViewModel = commentViewModel {
                        self.commentViewModels.append(commentViewModel)
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func emojiButtonPressed() {
        
    }
    
    func imageButtonPressed() {
        
    }
}

extension PostViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commentViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier) as? CommentTableViewCell else {
            fatalError()
        }
        cell.configure(with: commentViewModels[indexPath.row])
        if let captionHeroID = captionHeroID, let imageHeroID = imageHeroID {
            cell.setHeroIDs(forCaption: captionHeroID, forImage: imageHeroID)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let postViewModel = postViewModel, let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PostHeaderView.identifier) as? PostHeaderView else {
            return UIView()
        }
        if let postHeroID = postHeroID {
            headerView.setHeroID(id: postHeroID)
        }
        
        headerView.configure(with: postViewModel)
        
        return headerView
    }

}
