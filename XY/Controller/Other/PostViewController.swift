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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 375
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "Black")
        return tableView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setBackgroundColor(color: UIColor(0x333333), forState: .normal)
        return button
    }()
    
    private let typeView = TypeView()
    
    var onDismiss: (() -> Void)?
    
    var postViewModel: PostViewModel?
    
    var commentViewModels = [CommentViewModel]()
    
    var transitionId = "post"
    
    var tappedAnywhereGesture: UITapGestureRecognizer?
    
    init(with viewModel: PostViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(typeView)
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        postViewModel = viewModel
        
        let captionCommentViewModel = CommentViewModel(
            profileImage: viewModel.profileImage,
            text: viewModel.content,
            nickname: viewModel.nickname,
            timestamp: viewModel.timestamp,
            isLeft: true
        )
        
        commentViewModels.insert(captionCommentViewModel, at: 0)
        
        tableView.reloadData()
        
        // Fetch comments
        guard let postId = postViewModel?.postId else {
            return
        }
        PostManager.shared.getComments(for: postId) { (result) in
            switch result {
            case .success(let commentModels):
                for commentModel in commentModels {
                    PostManager.shared.buildComment(from: commentModel) { (commentViewModel) in
                        if let commentViewModel = commentViewModel {
//                            self.commentViewModels.append(commentViewModel)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        typeView.delegate = self
        
        tappedAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tappedAnywhereGesture!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame = CGRect(
            x: 12.75,
            y: view.safeAreaInsets.top - 5,
            width: 35,
            height: 35
        )
        
        typeView.frame = CGRect(
            x: 0,
            y: view.height - 40 - view.safeAreaInsets.bottom,
            width: view.width,
            height: 40
        )
        
        tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: closeButton.bottom + 5, left: 0, bottom: 40, right: 0))
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
        typeView.frame.origin.y -= keyboardSize.height - view.safeAreaInsets.bottom
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.contentInset = .zero
        typeView.frame.origin.y = view.height - 40 - view.safeAreaInsets.bottom
    }
    
    @objc func tappedAnywhere() {
        typeView.resignFirstResponder()
    }
}

extension PostViewController : TypeViewDelegate {
    func sendButtonPressed(text: String) {
        // Upload comment
        PostManager.shared.uploadComment(forPost: postViewModel!.postId, comment: text) { (result) in
            switch result {
            case .success(let comment):
                PostManager.shared.buildComment(from: comment) { (commentViewModel) in
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
        
        if indexPath.row == 0 {
            cell.setHeroIDs(forCaption: "caption", forImage: "image")
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
        
        headerView.setHeroID(id: transitionId)
        
        headerView.configure(with: postViewModel)
        
        return headerView
    }
    
}
