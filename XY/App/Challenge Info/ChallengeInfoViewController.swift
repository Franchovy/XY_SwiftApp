//
//  ChallengeInfoViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/05/2021.
//

import UIKit

class ChallengeInfoViewController: UIViewController {
    
    private let challengeCard = ChallengeCard()
    private let sentToLabel = Label("Sent To", style: .title, fontSize: 25)
    private let userStatusCollectionView = ChallengeStatusCollectionView()
    
    var viewModel: ChallengeCardViewModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(challengeCard)
        view.addSubview(sentToLabel)
        view.addSubview(userStatusCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeCard.frame = CGRect(
            x: (view.width - 180)/2,
            y: 15,
            width: 180,
            height: 250
        )
        
        sentToLabel.sizeToFit()
        sentToLabel.frame = CGRect(
            x: 15,
            y: challengeCard.bottom + 42,
            width: sentToLabel.width,
            height: sentToLabel.height
        )
        
        userStatusCollectionView.frame = CGRect(
            x: 15,
            y: sentToLabel.bottom + 10,
            width: view.width - 30,
            height: view.height - sentToLabel.bottom - 10
        )
    }
    
    public func configure(with viewModel: ChallengeCardViewModel) {
        self.viewModel = viewModel
        
        userStatusCollectionView.configure(with: viewModel)
    }
}
