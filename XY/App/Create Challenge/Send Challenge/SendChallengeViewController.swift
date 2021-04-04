//
//  SendChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class SendChallengeViewController: UIViewController, SendToFriendsViewControllerDelegate {

    private var challengeCard: ChallengeCard
    private let sendToFriendsViewController = SendToFriendsViewController()
    
    init(with viewModel: ChallengeCardViewModel) {
        challengeCard = ChallengeCard(with: viewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        sendToFriendsViewController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonPressed))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
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
    
    func sendToFriendDelegate(_ sendToList: [SendCollectionViewCellViewModel]) {
        if sendToList.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc private func sendButtonPressed() {
        let friendsDataSource = FriendsDataSource(fromList: sendToFriendsViewController.selectedFriendsToSend)
        
        isHeroEnabled = true
        challengeCard.heroID = "challengeCard"
        
        let vc = ConfirmSendChallengeViewController(challengeCardViewModel: challengeCard.viewModel, friendsList: friendsDataSource)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
