//
//  ProfileHeaderConversationsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

class ProfileHeaderConversationsViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 45
        tableView.allowsMultipleSelection = true
//        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: ChatBubbleTableViewCell.identifier)
        return tableView
    }()
    
//    var viewModels = [MessageViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
//        tableView.dataSource = self
//        tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func configure(with viewModel: ConversationViewModel) {
        
    }
    
}
//
//extension ProfileHeaderConversationsViewController : UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
//
//
//}
