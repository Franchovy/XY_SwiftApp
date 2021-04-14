//
//  ConfirmSendChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class ConfirmSendChallengeViewController: UIViewController {
    
    private let youChallengedLabel = Label("You challenged:", style: .title)
    private let toLabel = Label("To perform:", style: .title)
    
    private let friendsCollectionView = FriendsCollectionView()
    private let friendsDataSource: FriendsDataSource

    private let card = ChallengeCard()
    
    private let backHomeButton = Button(title: "Back home", style: .roundButton(backgroundColor: UIColor(0x007BF5)), paddingVertical: 6, paddingHorizontal: 15)
    private let takeAnotherButton = Button(title: "Take another", style: .roundButtonBorder(gradient: Global.xyGradient), paddingVertical: 6, paddingHorizontal: 15)
    
    init(challengeCardViewModel: ChallengeCardViewModel, friendsList: FriendsDataSource) {
        friendsDataSource = friendsList
        card.configure(with: challengeCardViewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        friendsCollectionView.dataSource = friendsDataSource
        
        isHeroEnabled = true
        card.heroID = "challengeCard"
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.visible)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backHomeButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        takeAnotherButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        takeAnotherButton.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        
        view.addSubview(youChallengedLabel)
        view.addSubview(toLabel)
        view.addSubview(friendsCollectionView)
        view.addSubview(card)
        view.addSubview(backHomeButton)
        view.addSubview(takeAnotherButton)
        
        backHomeButton.addTarget(self, action: #selector(tappedHomeButton), for: .touchUpInside)
        takeAnotherButton.addTarget(self, action: #selector(tappedTakeAnotherButton), for: .touchUpInside)
        
        navigationItem.title = "Confirm Send"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        youChallengedLabel.sizeToFit()
        youChallengedLabel.frame = CGRect(
            x: 25,
            y: 98,
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
        
        let cardSize = CGSize(width: 181, height: 284)
        card.frame = CGRect(
            x: (view.width - cardSize.width)/2,
            y: toLabel.bottom + 15,
            width: cardSize.width,
            height: cardSize.height
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
        
    }
    
    @objc private func tappedHomeButton() {
        if let vc = navigationController?.viewControllers.last(where: {$0 is HomeViewController}) {
            navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    @objc private func tappedTakeAnotherButton() {
        if let vc = navigationController?.viewControllers.last(where: {$0 is CameraViewController}) {
            navigationController?.popToViewController(vc, animated: true)
        }
    }

}
