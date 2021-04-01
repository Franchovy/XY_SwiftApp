//
//  ProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let profileBubble = FriendBubble()
    private let friendButton = AddFriendButton()
    private let friendsLabel = Label("Friends", style: .body, fontSize: 15)
    private let challengesLabel = Label("Challenges", style: .body, fontSize: 15)
    private let numFriendsLabel = Label(style: .body, fontSize: 25)
    private let numChallengesLabel = Label(style: .body, fontSize: 25)
    
    private var viewModel: ProfileViewModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(profileBubble)
        view.addSubview(friendButton)
        view.addSubview(friendsLabel)
        view.addSubview(challengesLabel)
        view.addSubview(numFriendsLabel)
        view.addSubview(numChallengesLabel)
        
        friendButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 20)
        
        profileBubble.imageView.layer.borderWidth = 1
        profileBubble.imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Raleway-Heavy", size: 25)!
        ]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Raleway-Bold", size: 20)!
        ]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let profileBubbleSize:CGFloat = 110
        profileBubble.frame = CGRect(
            x: (view.width - profileBubbleSize)/2,
            y: 10,
            width: profileBubbleSize,
            height: profileBubbleSize
        )
        
        friendButton.sizeToFit()
        friendButton.frame = CGRect(
            x: (view.width - friendButton.width)/2,
            y: profileBubble.bottom + 10.5,
            width: friendButton.width,
            height: friendButton.height
        )
        
        numFriendsLabel.sizeToFit()
        numFriendsLabel.frame = CGRect(
            x: profileBubble.left + 5 - numFriendsLabel.width/2,
            y: friendButton.bottom + 10.5,
            width: numFriendsLabel.width,
            height: numFriendsLabel.height
        )
        
        numChallengesLabel.sizeToFit()
        numChallengesLabel.frame = CGRect(
            x: profileBubble.right - 5 - numChallengesLabel.width/2,
            y: friendButton.bottom + 10.5,
            width: numChallengesLabel.width,
            height: numChallengesLabel.height
        )
        
        friendsLabel.sizeToFit()
        friendsLabel.frame = CGRect(
            x: profileBubble.left + 5 - friendsLabel.width/2,
            y: numFriendsLabel.bottom + 3,
            width: friendsLabel.width,
            height: friendsLabel.height
        )
        
        challengesLabel.sizeToFit()
        challengesLabel.frame = CGRect(
            x: profileBubble.right - 5 - challengesLabel.width/2,
            y: numChallengesLabel.bottom + 3,
            width: challengesLabel.width,
            height: challengesLabel.height
        )
        
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        navigationItem.title = viewModel.nickname
        
        numFriendsLabel.text = String(describing: viewModel.numFriends)
        numChallengesLabel.text = String(describing: viewModel.numChallenges)
        
        profileBubble.setImage(viewModel.profileImage)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        profileBubble.imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor
    }
}
