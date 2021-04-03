//
//  ConfirmSendChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class ConfirmSendChallengeViewController: UIViewController {
    
    private let youChallengedLabel = Label("You challenged:", style: .title)
    private let toLabel = Label("To:", style: .title)
    
    private let friendsCollectionView = FriendsCollectionView()
    private let friendsDataSource: FriendsDataSource

    private let card: ChallengeCard
    
    private let backHomeButton = Button(title: "Back home", style: .roundButton(backgroundColor: UIColor(0x007BF5)), paddingVertical: 13, paddingHorizontal: 15)
    private let takeAnotherButton = Button(title: "Take another", style: .roundButtonBorder(gradient: Global.xyGradient), paddingVertical: 13, paddingHorizontal: 15)
    
    init(challengeCardViewModel: ChallengeCardViewModel, friendsList: FriendsDataSource) {
        friendsDataSource = friendsList
        card = ChallengeCard(with: challengeCardViewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        friendsCollectionView.dataSource = friendsDataSource
        
        isHeroEnabled = true
        card.heroID = "challengeCard"
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(youChallengedLabel)
        view.addSubview(toLabel)
        view.addSubview(friendsCollectionView)
        view.addSubview(card)
        view.addSubview(backHomeButton)
        view.addSubview(takeAnotherButton)
        
        navigationItem.title = "Confirm Send"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        youChallengedLabel.sizeToFit()
        youChallengedLabel.frame = CGRect(
            x: 25,
            y: 15,
            width: youChallengedLabel.width,
            height: youChallengedLabel.height
        )
        
        friendsCollectionView.frame = CGRect(
            x: 15,
            y: youChallengedLabel.bottom + 15,
            width: view.width - 15,
            height: 99
        )
        
        toLabel.sizeToFit()
        toLabel.frame = CGRect(
            x: 15.69,
            y: friendsCollectionView.bottom + 20,
            width: toLabel.width,
            height: toLabel.height
        )
        
        takeAnotherButton.sizeToFit()
        takeAnotherButton.frame = CGRect(
            x: (view.width - takeAnotherButton.width)/2,
            y: view.height - 45 - takeAnotherButton.height,
            width: takeAnotherButton.width,
            height: takeAnotherButton.height
        )
        
        backHomeButton.sizeToFit()
        backHomeButton.frame = CGRect(
            x: (view.width - backHomeButton.width)/2,
            y: takeAnotherButton.top - 11 - backHomeButton.height,
            width: backHomeButton.width,
            height: backHomeButton.height
        )
        
        let cardSize = CGSize(width: 181, height: 284)
        card.frame = CGRect(
            x: (view.width - cardSize.width)/2,
            y: backHomeButton.top - 15 - cardSize.height,
            width: cardSize.width,
            height: cardSize.height
        )
        
    }

}
