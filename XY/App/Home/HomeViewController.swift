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
    
    private let welcomeGradientLabel = GradientLabel(text: "Welcome To XY!", fontSize: 40, gradientColours: Global.xyGradient)
    private let welcomeTextLabel = Label("Here you'll find your challenges, but you need to add a friend to start.", style: .body, fontSize: 20)
    private let addFriendButton = GradientBorderButtonWithShadow()
    
    private let noChallengesLabel = Label("You have no challenges.", style: .body, fontSize: 18)
    private let createChallengeButton = GradientBorderButtonWithShadow()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        NavigationControlManager.mainViewController = self
        
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
        
        createChallengeButton.setTitle("Create challenge", for: .normal)
        createChallengeButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        createChallengeButton.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        createChallengeButton.setGradient(Global.xyGradient)
        createChallengeButton.setBackgroundColor(color: UIColor(named: "XYBackground")!)
        
        createChallengeButton.addTarget(self, action: #selector(tappedCreateChallenge), for: .touchUpInside)
            
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
        
        navigationController?.configureBackgroundStyle(.visible)
        configureBackButton(.backButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch HomeStateManager.state {
        case .noFriends:
            challengesLabel.isHidden = true
            createChallengeButton.isHidden = true
            configureEmptyNoFriends()
        case .noChallengesFirst, .noChallengesNormal:
            configureEmptyNoChallenges()
            scrollView.addSubview(createChallengeButton)
        case .normal:
            scrollView.addSubview(createChallengeButton)
        default: break
        }
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
            height: 86
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
        
        welcomeGradientLabel.sizeToFit()
        welcomeGradientLabel.frame = CGRect(
            x: (view.width - welcomeGradientLabel.width)/2,
            y: friendsCollectionView.bottom + 50,
            width: welcomeGradientLabel.width,
            height: welcomeGradientLabel.height
        )
        
        welcomeTextLabel.setFrameWithAutomaticHeight(
            x: 43.1,
            y: welcomeGradientLabel.bottom + 33.56,
            width: view.width - 86.2
        )
        
        let buttonSize = CGSize(width: 245, height: 59)
        
        addFriendButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: view.height * 0.64,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        noChallengesLabel.sizeToFit()
        noChallengesLabel.frame = CGRect(
            x: (view.width - noChallengesLabel.width)/2,
            y: challengesLabel.bottom + 20.02,
            width: noChallengesLabel.width,
            height: noChallengesLabel.height
        )
        
        createChallengeButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: HomeStateManager.state == .normal ?
                view.height * 0.69 :
                noChallengesLabel.bottom + 22.02,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    private func configureEmptyNoFriends() {
        scrollView.addSubview(welcomeGradientLabel)
        scrollView.addSubview(welcomeTextLabel)
        scrollView.addSubview(addFriendButton)
        
        welcomeTextLabel.numberOfLines = 0
        welcomeTextLabel.textAlignment = .center
        
        addFriendButton.setTitle("Find friends", for: .normal)
        addFriendButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        addFriendButton.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        addFriendButton.setGradient(Global.xyGradient)
        addFriendButton.setBackgroundColor(color: UIColor(named: "XYBackground")!)
    }
    
    private func configureEmptyNoChallenges() {
        scrollView.addSubview(noChallengesLabel)
    }
    
    @objc private func tappedNotifications() {
        let vc = NotificationsViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tappedSearch() {
        let vc = FindFriendsViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tappedCreateChallenge() {
        let vc = CreateChallengeViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
