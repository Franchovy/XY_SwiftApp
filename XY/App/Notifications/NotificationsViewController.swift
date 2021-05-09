//
//  NotificationsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    private let collectionView = NotificationsCollectionView()
    private let dataSource = NotificationsDataSource()
    
    private let refreshControl = UIRefreshControl()
    
//    private let noNotificationsLabel = Label("Find friends or create a challenge to receive more notifications!", style: .body, fontSize: 18)
//    private let findFriendsButton = GradientBorderButtonWithShadow()
//    private let createChallengeButton = GradientBorderButtonWithShadow()
    
    private let notificationsComingSoonLabel = Label("Notifications coming soon...", style: .bodyBold, fontSize: 18)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(notificationsComingSoonLabel)
//        notificationsComingSoonLabel.hoverAnimate()
        
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
        collectionView.dataSource = dataSource
        dataSource.delegate = collectionView

        collectionView.addSubview(refreshControl)
        refreshControl.tintColor = .XYTint
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        navigationItem.title = "Notifications"
        
        NotificationsDataManager.shared.loadFromStorage()
        NotificationsDataManager.shared.fetchNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadNotifications), name: .didLoadNewNotifications, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.backButton)
        navigationController?.configureBackgroundStyle(.visible)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
        
        notificationsComingSoonLabel.sizeToFit()
        notificationsComingSoonLabel.frame = CGRect(
            x: (view.width - notificationsComingSoonLabel.width)/2,
            y: (view.height - notificationsComingSoonLabel.height)/2,
            width: notificationsComingSoonLabel.width,
            height: notificationsComingSoonLabel.height
        )
    }
    
    @objc private func didLoadNotifications() {
        dataSource.reload()
        collectionView.reloadData()
    }
    
    @objc private func didPullToRefresh() {
        refreshControl.beginRefreshing()
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        NotificationsDataManager.shared.fetchNotifications() {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.refreshControl.endRefreshing()
            self.dataSource.reload()
            self.collectionView.reloadData()
        }
    }
}
