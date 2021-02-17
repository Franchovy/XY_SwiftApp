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
    
    private let writeCommentButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.setBackgroundColor(color: UIColor(0x333333), forState: .normal)
        return button
    }()
    
    var onDismiss: (() -> Void)?
    
    var postViewModel: PostViewModel?
    
    var commentViewModels = [CommentViewModel]()
    
    var transitionId = "post"
    
    init(with viewModel: PostViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(writeCommentButton)
        
        writeCommentButton.addTarget(self, action: #selector(writeCommentButtonPressed), for: .touchUpInside)
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
                            self.commentViewModels.append(commentViewModel)
                            self.tableView.reloadData()
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
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame = CGRect(
            x: 12.75,
            y: view.safeAreaInsets.top - 5,
            width: 35,
            height: 35
        )
        
        writeCommentButton.frame = CGRect(
            x: view.width - 35 - 12.75,
            y: view.height - 35 - 12.75,
            width: 35,
            height: 35
        )
        
        tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: closeButton.bottom + 5, left: 0, bottom: 0, right: 0))
    }
    
    @objc private func closeButtonPressed() {
        dismiss(animated: true, completion: { self.onDismiss?() })
    }
    
    @objc private func writeCommentButtonPressed() {
        // open comment view
        
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
