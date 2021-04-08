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
    
    private let friendsLabelView = LabelView()
    private let challengeLabelView = LabelView()
    
    private let startChallengeLabel = Label("Start a challenge with ", style: .body, fontSize: 15)
    private let startChallengeNameLabel = Label(style: .nickname, fontSize: 15)
    private let challengeButton = GradientBorderButtonWithShadow()
    
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
        view.addSubview(friendsLabelView)
        view.addSubview(challengeLabelView)
        view.addSubview(startChallengeLabel)
        view.addSubview(startChallengeNameLabel)
        view.addSubview(challengeButton)
        
        friendButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 20)
        
        profileBubble.imageView.layer.borderWidth = 1
        profileBubble.imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor
        
        challengeButton.setBackgroundColor(color: UIColor(named: "XYBackground")!)
        challengeButton.setGradient(Global.xyGradient)
        challengeButton.setTitle("Challenge", for: .normal)
        challengeButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        challengeButton.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        
        challengeButton.addTarget(self, action: #selector(didTapChallengeButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.backButton)
        navigationController?.configureBackgroundStyle(.visible)
        
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
        
        friendsLabelView.sizeToFit()
        friendsLabelView.frame = CGRect(
            x: profileBubble.left + 5 - friendsLabelView.width/2,
            y: friendButton.bottom + 10,
            width: friendsLabelView.width,
            height: friendsLabelView.height
        )
        
        challengeLabelView.sizeToFit()
        challengeLabelView.frame = CGRect(
            x: profileBubble.right - 5 - challengeLabelView.width/2,
            y: friendButton.bottom + 10,
            width: challengeLabelView.width,
            height: challengeLabelView.height
        )
        
        startChallengeLabel.sizeToFit()
        startChallengeNameLabel.sizeToFit()
        
        let startChallengeLabelsTotalWidth = startChallengeLabel.width + startChallengeNameLabel.width
        
        startChallengeLabel.frame = CGRect(
            x: (view.width - startChallengeLabelsTotalWidth)/2,
            y: view.height/2 - 80,
            width: startChallengeLabel.width,
            height: startChallengeLabel.height
        )
        
        startChallengeNameLabel.frame = CGRect(
            x: startChallengeLabel.right,
            y: startChallengeLabel.top,
            width: startChallengeNameLabel.width,
            height: startChallengeNameLabel.height
        )
        
        let challengeButtonSize = CGSize(width: 237, height: 50)
        challengeButton.frame = CGRect(
            x: (view.width - challengeButtonSize.width)/2,
            y: startChallengeLabel.bottom + 17,
            width: challengeButtonSize.width,
            height: challengeButtonSize.height
        )
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        navigationItem.title = viewModel.nickname
        startChallengeNameLabel.text = viewModel.nickname
        
        friendsLabelView.addLabel(String(describing: viewModel.numFriends), font: UIFont(name: "Raleway-Medium", size: 25)!)
        friendsLabelView.addLabel("Friends", font: UIFont(name: "Raleway-Medium", size: 15)!)
        friendsLabelView.addOnPress {
            let prompt = Prompt()
            prompt.setTitle(text: "Friends")
            let numFriendsText = "\(viewModel.numFriends) friends"
            prompt.addTextWithBoldInRange(text: "You have \(numFriendsText) to challenge.", range: NSRange(location: 9, length: numFriendsText.count))
            prompt.addCompletionButton(buttonText: "Ok", style: .embedded, closeOnTap: true)
            
            self.view.addSubview(prompt)
            prompt.appear()
        }
        
        challengeLabelView.addLabel(String(describing: viewModel.numChallenges), font: UIFont(name: "Raleway-Medium", size: 25)!)
        challengeLabelView.addLabel("Challenges", font: UIFont(name: "Raleway-Medium", size: 15)!)
        challengeLabelView.addOnPress {
            let prompt = Prompt()
            prompt.setTitle(text: "Friends")
            let numFriendsText = "\(viewModel.numFriends) friends"
            prompt.addTextWithBoldInRange(text: "You have \(numFriendsText) to challenge.", range: NSRange(location: 9, length: numFriendsText.count))
            prompt.addCompletionButton(buttonText: "Ok", style: .embedded, closeOnTap: true)
            
            self.view.addSubview(prompt)
            prompt.appear()
        }
        
        profileBubble.setImage(viewModel.profileImage)
        
        friendButton.configure(for: viewModel.friendStatus)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        profileBubble.imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor
    }
    
    @objc private func didTapChallengeButton() {
        let vc = CreateChallengeViewController()
        
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
}
