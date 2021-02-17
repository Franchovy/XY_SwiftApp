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
    
    private let notificationsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var viewModels = [ConversationViewModel]()
    
    var notificationsIsOn = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(notificationsImage)
        
        if let value = UserDefaults.standard.object(forKey: "pushNotificationsEnabled") as? Bool {
            setNotificationState(to: value)
        } else {
            setNotificationState(to: false)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(notificationsToggled))
        notificationsImage.isUserInteractionEnabled = true
        notificationsImage.addGestureRecognizer(gesture)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
        notificationsImage.frame = CGRect(
            x: view.width - 25 - 5,
            y: 5,
            width: 25,
            height: 25
        )
    }
    
    func configure(with viewModels: [ConversationViewModel]) {
        self.viewModels = viewModels
        
        tableView.reloadData()
    }
    
    private func setNotificationState(to value: Bool) {
        UserDefaults.standard.setValue(value, forKey: "pushNotificationsEnabled")
        notificationsIsOn = value
        notificationsImage.image = value ? UIImage(systemName: "bell.circle.fill") : UIImage(systemName: "bell.slash.circle.fill")
    }
    
    @objc private func notificationsToggled() {
        setNotificationState(to: !notificationsIsOn)
        if notificationsIsOn {
            guard let userId = AuthManager.shared.userId else {
                return
            }
            let pushNotificationManager = PushNotificationManager.init(userID: userId)
            pushNotificationManager.registerForPushNotifications()
        }
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
