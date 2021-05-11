//
//  SendChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class SendChallengeViewController: UIViewController, SendToFriendsViewControllerDelegate {

    private var challengeCard = ChallengeCard()
    private let sendToFriendsViewController = SendToFriendsViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        sendToFriendsViewController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        configureChallengeCard()
        if CreateChallengeManager.shared.acceptedChallenge != nil {
            configureForAcceptedChallenge()
        }
        
        navigationController?.configureBackgroundStyle(.visible)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(sendToFriendsViewController)
        view.addSubview(sendToFriendsViewController.view)
        
        view.addSubview(challengeCard)
        challengeCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(challengeTapped)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(closeButtonPressed))
        
        navigationItem.title = "Send Challenge"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeCard.frame = CGRect(
            x: (view.width - 181)/2,
            y: 15,
            width: 181,
            height: 284
        )
        
        sendToFriendsViewController.view.frame = CGRect(
            x: 0,
            y: 300,
            width: view.width,
            height: view.height - 300
        )
    }
    
    public func configureChallengeCard() {
        guard let viewModel = CreateChallengeManager.shared.getChallengeCardViewModel() else {
            return
        }
        
        challengeCard.configure(with: viewModel)
    }
    
    func sendToFriendDelegate(_ sendToList: [UserViewModel]) {
        if sendToList.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func configureForAcceptedChallenge() {
        guard let acceptedChallenge = CreateChallengeManager.shared.acceptedChallenge else {
            return
        }
        
        if var friendsList = acceptedChallenge.friendBubbles {
            if let senderProfile = acceptedChallenge.senderProfile {
                friendsList.append(senderProfile)
            }
            
            print("Friends list: \(friendsList.map({$0.coreDataID}))")
            sendToFriendsViewController.selectFriends(friendsList.map({$0.coreDataID}))
        }
    }
    
    @objc private func challengeTapped() {
        let vc = DescriptionViewController()
        vc.loadFromManager()
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func closeButtonPressed() {
        let prompt = Prompt()
        prompt.setTitle(text: "Discard Challenge")
        prompt.addText(text: "Are you sure you want to quit? Your video will be lost.")
        prompt.addCompletionButton(buttonText: "Quit", textColor: UIColor(0xEF3A30), style: .embedded, onTap: {
            NavigationControlManager.backToCamera()
        })
        prompt.addCompletionButton(buttonText: "Cancel", style: .embedded, closeOnTap: true)
        
        view.addSubview(prompt)
        prompt.appear()
    }
    
    @objc private func sendButtonPressed() {
        
        guard let viewModel = challengeCard.viewModel else {
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        CreateChallengeManager.shared.friendsToChallengeList = sendToFriendsViewController.selectedFriendsToSend
        
        let prompt = Prompt()
        prompt.tapEscapable = false
        prompt.setTitle(text: "Preparing to upload...")
        prompt.addLoadingCircle(initialProgress: 0.0)
        
        navigationController?.view.addSubview(prompt)
        prompt.appear()
        
        CreateChallengeManager.shared.startUploadChallenge() { progress in
            prompt.setLoadingProgress(progress: progress)
        } preparingCompletion: { error in
            if let error = error {
                print("Error uploading challenge: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    prompt.disappear()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        self.isHeroEnabled = true
                        self.challengeCard.heroID = "challengeCard"
                        
                        let vc = ConfirmSendChallengeViewController(challengeCardViewModel: viewModel, friendsList: self.sendToFriendsViewController.selectedFriendsToSend)
                        vc.isHeroEnabled = true
                        self.navigationController?.isHeroEnabled = true
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
