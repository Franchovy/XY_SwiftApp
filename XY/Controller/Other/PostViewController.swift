//
//  PostViewController.swift
//  XY
//
//  Created by Maxime Franchot on 17/02/2021.
//

import UIKit

class PostViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostHeaderView.self, forHeaderFooterViewReuseIdentifier: PostHeaderView.identifier)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 375
        return tableView
    }()
    
    var postViewModel: PostViewModel?
    
    var commentViewModels: [CommentViewModel] = [
        CommentViewModel(
            profileImage: UIImage(named: "testface"),
            text: "Wow, this is super cool",
            nickname: "Spongebob",
            timestamp: Date(),
            isLeft: false
        ),
        CommentViewModel(
            profileImage: UIImage(named: "testface"),
            text: "Wow, this is epic",
            nickname: "Spongebob",
            timestamp: Date(),
            isLeft: false
        ),
        CommentViewModel(
            profileImage: UIImage(named: "testface"),
            text: "I love this post",
            nickname: "Spongebob",
            timestamp: Date(),
            isLeft: false
        )
    ]
    
    init(with viewModel: PostViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
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
        
        tableView.frame = view.bounds
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
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let postViewModel = postViewModel, let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PostHeaderView.identifier) as? PostHeaderView else {
            return UIView()
        }
        
        headerView.configure(with: postViewModel)
        
        return headerView
    }
    
}
