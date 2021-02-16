//
//  ProfileHeaderConversationsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

protocol ProfileConversationsViewControllerDelegate {
    func openConversation(with viewModel: ConversationViewModel)
}

class ProfileHeaderConversationsViewController: UIViewController {

    var delegate: ProfileConversationsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 90
        tableView.allowsSelection = true
        tableView.register(ConversationPreviewTableViewCell.self, forCellReuseIdentifier: ConversationPreviewTableViewCell.identifier)
        return tableView
    }()
    
    var viewModels = [ConversationViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
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
    
    func configure(with viewModels: [ConversationViewModel]) {
        self.viewModels = viewModels
        
        tableView.reloadData()
    }
    
}

extension ProfileHeaderConversationsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationPreviewTableViewCell.identifier) as? ConversationPreviewTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.row]
        delegate?.openConversation(with: viewModel)
    }
}
