//
//  EditProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    private let profileImage = EditProfileImageView()
    private let nicknameTextField = EditNicknameTextField()
    
    private let friendsLabel = Label("Friends", style: .info, fontSize: 15)
    private let challengesLabel = Label("Challenges", style: .info, fontSize: 15)
    private let numFriendsLabel = Label(style: .info, fontSize: 25)
    private let numChallengesLabel = Label(style: .info, fontSize: 25)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(profileImage)
        view.addSubview(nicknameTextField)
        view.addSubview(friendsLabel)
        view.addSubview(challengesLabel)
        view.addSubview(numFriendsLabel)
        view.addSubview(numChallengesLabel)
        
        configure()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere)))
        
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .done, target: self, action: #selector(didTapSettings))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let profileImageSize:CGFloat = 110
        profileImage.frame = CGRect(
            x: (view.width - profileImageSize)/2,
            y: 20,
            width: profileImageSize,
            height: profileImageSize
        )
        
        nicknameTextField.sizeToFit()
        nicknameTextField.frame = CGRect(
            x: (view.width - nicknameTextField.width)/2,
            y: profileImage.bottom + 15,
            width: nicknameTextField.width,
            height: nicknameTextField.height
        )
        
        numFriendsLabel.sizeToFit()
        numFriendsLabel.frame = CGRect(
            x: profileImage.left + 5 - numFriendsLabel.width/2,
            y: nicknameTextField.bottom + 10.5,
            width: numFriendsLabel.width,
            height: numFriendsLabel.height
        )
        
        numChallengesLabel.sizeToFit()
        numChallengesLabel.frame = CGRect(
            x: profileImage.right - 5 - numChallengesLabel.width/2,
            y: nicknameTextField.bottom + 10.5,
            width: numChallengesLabel.width,
            height: numChallengesLabel.height
        )
        
        friendsLabel.sizeToFit()
        friendsLabel.frame = CGRect(
            x: profileImage.left + 5 - friendsLabel.width/2,
            y: numFriendsLabel.bottom + 3,
            width: friendsLabel.width,
            height: friendsLabel.height
        )
        
        challengesLabel.sizeToFit()
        challengesLabel.frame = CGRect(
            x: profileImage.right - 5 - challengesLabel.width/2,
            y: numChallengesLabel.bottom + 3,
            width: challengesLabel.width,
            height: challengesLabel.height
        )
    }
    
    private func configure() {
        nicknameTextField.text = "sexyBoss_666"
        nicknameTextField.sizeToFit()
        
        numFriendsLabel.text = String(describing: Int.random(in: 0...1000))
        numChallengesLabel.text = String(describing: Int.random(in: 0...1000))
    }
    
    @objc private func didTapSettings() {
        
    }
    
    @objc private func tappedAnywhere() {
        nicknameTextField.resignFirstResponder()
    }
}
