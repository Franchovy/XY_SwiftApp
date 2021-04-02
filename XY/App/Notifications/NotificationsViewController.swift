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
    
    private let noNotificationsLabel = Label("Find friends or create a challenge to receive more notifications!", style: .body, fontSize: 18)
    private let findFriendsButton = GradientBorderButtonWithShadow()
    private let createChallengeButton = GradientBorderButtonWithShadow()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.dataSource = dataSource
        
        if collectionView.numberOfItems(inSection: 0) == 0 {
            configureEmpty()
        }
        
        navigationItem.title = "Notifications"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
        
        noNotificationsLabel.setFrameWithAutomaticHeight(
            x: 26.5,
            y: 70,
            width: view.width - 53
        )
        
        let buttonSize = CGSize(width: 237, height: 50)
        
        findFriendsButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: noNotificationsLabel.bottom + 46,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        createChallengeButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: findFriendsButton.bottom + 26.87,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    private func configureEmpty() {
        view.addSubview(noNotificationsLabel)
        view.addSubview(findFriendsButton)
        view.addSubview(createChallengeButton)
        
        noNotificationsLabel.numberOfLines = 0
        noNotificationsLabel.lineBreakMode = .byWordWrapping
        noNotificationsLabel.textAlignment = .center
        
        findFriendsButton.setGradient(Global.xyGradient)
        findFriendsButton.setBackgroundColor(color: UIColor(named: "XYBackground")!)
        findFriendsButton.setTitle("Find friends", for: .normal)
        findFriendsButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
        
        createChallengeButton.setGradient(Global.xyGradient)
        createChallengeButton.setBackgroundColor(color: UIColor(named: "XYBackground")!)
        createChallengeButton.setTitle("Create new", for: .normal)
        createChallengeButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 25)
    }
}
