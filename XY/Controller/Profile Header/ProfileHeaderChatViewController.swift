//
//  ProfileHeaderChatViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

class ProfileHeaderChatViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        tableView.allowsMultipleSelection = true
        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: ChatBubbleTableViewCell.identifier)
        return tableView
    }()
    
    private let typeView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private let emojiButton: UIButton = {
        let button = UIButton()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(0x3F63F7).cgColor,
            UIColor(0x58A5FF).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
        gradientLayer.locations = [0, 1]
        button.layer.addSublayer(gradientLayer)
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        return button
    }()
    
    var viewModels:[MessageViewModel] = [
        MessageViewModel(
            text: "Yo man, ready for China?",
            timestamp: Date(),
            nickname: "CEO",
            senderIsSelf: false
        ),
        MessageViewModel(
            text: "Hey dude, give me two minutes, I got problems with the new viewcontroller again.",
            timestamp: Date(),
            nickname: "CTO",
            senderIsSelf: true
        ),
        MessageViewModel(
            text: "Wow, you really still developing the app yourself? God damn.",
            timestamp: Date(),
            nickname: "CEO",
            senderIsSelf: false
        )
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(tableView)
        
        typeView.addSubview(emojiButton)
        view.addSubview(typeView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        
        let typeViewHeight:CGFloat = 40
        typeView.frame = CGRect(
            x: 0,
            y: view.height - typeViewHeight,
            width: view.width,
            height: typeViewHeight
        )
        
        emojiButton.frame = CGRect(
            x: 15,
            y: 1,
            width: 38,
            height: 38
        )
    }
    
}

extension ProfileHeaderChatViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as? ChatBubbleTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    
}
