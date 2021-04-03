//
//  SendChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class SendChallengeViewController: UIViewController {

    private var challengeCard: ChallengeCard
    private let sendToFriendsViewController = SendToFriendsViewController()
    
    init(with viewModel: ChallengeCardViewModel) {
        challengeCard = ChallengeCard(with: viewModel)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(sendToFriendsViewController)
        view.addSubview(sendToFriendsViewController.view)
        
        view.addSubview(challengeCard)
        
        navigationItem.title = "Send Challenge"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeCard.frame = CGRect(
            x: (view.width - challengeCard.width)/2,
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
}
