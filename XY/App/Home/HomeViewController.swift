//
//  HomeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private let friendsLabel = Label("Friends", style: .title)
    private let friendsCollectionView = FriendsCollectionView()
    
    private let challengesLabel = Label("Your Challenges", style: .title)
    private let challengesCollectionView = ChallengesCollectionView()
    
    private let challengesDataSource = ChallengesManager()
    private let friendsDataSource = FriendsDataSource()

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
        challengesCollectionView.dataSource = challengesDataSource
        friendsCollectionView.dataSource = friendsDataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        scrollView.addSubview(friendsLabel)
        scrollView.addSubview(friendsCollectionView)
        scrollView.addSubview(challengesLabel)
        scrollView.addSubview(challengesCollectionView)
        
        let logoView = UIImageView(image: UIImage(named: "XYLogo"))
        logoView.contentMode = .scaleAspectFit
        logoView.frame.size = CGSize(width: 53.36, height: 28.4)
        
        navigationItem.titleView = logoView
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor(named: "XYTint")!, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(tappedSearch)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "bell.fill")?.withTintColor(UIColor(named: "XYTint")!, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(tappedNotifications)
            )
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(named: "XYBackground")
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        friendsLabel.sizeToFit()
        friendsLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: friendsLabel.width,
            height: friendsLabel.height
        )
        
        friendsCollectionView.frame = CGRect(
            x: 10,
            y: friendsLabel.bottom + 10,
            width: view.width - 20,
            height: 66
        )
        
        challengesLabel.sizeToFit()
        challengesLabel.frame = CGRect(
            x: 10,
            y: friendsCollectionView.bottom + 12,
            width: challengesLabel.width,
            height: challengesLabel.height
        )
        
        challengesCollectionView.frame = CGRect(
            x: 10,
            y: challengesLabel.bottom + 10,
            width: view.width - 20,
            height: 200
        )
    }
    
    @objc private func tappedNotifications() {
        
    }
    
    @objc private func tappedSearch() {
        
    }
}
