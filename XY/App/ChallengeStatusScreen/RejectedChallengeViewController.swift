//
//  RejectedChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit

class RejectedChallengeViewController: UIViewController {

    private let challengeCard = ChallengeCard()
    private let rejectedLabel = Label("Rejected", style: .title, fontSize: 42)
    private let infoLabel = Label(style: .info, fontSize: 20)
    private let backHomeButton = Button(title: "Back home", style: .roundButton(backgroundColor: UIColor(0x007BF5)), font: UIFont(name: "Raleway-Heavy", size: 15), paddingVertical: 13, paddingHorizontal: 15)
    
    init(viewModel: ChallengeCardViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        challengeCard.configure(with: viewModel, withoutTag: true)
        if let nickname = viewModel.senderProfile?.nickname {
            infoLabel.text = "You rejected \(nickname)'s challenge."
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rejectedLabel.textColor = UIColor(0xEF3A30)
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        view.addSubview(challengeCard)
        view.addSubview(rejectedLabel)
        view.addSubview(infoLabel)
        view.addSubview(backHomeButton)
        
        backHomeButton.addTarget(self, action: #selector(backHomeButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let challengeCardSize = CGSize(width: 181, height: 284)
        challengeCard.frame = CGRect(
            x: (view.width - challengeCardSize.width)/2,
            y: 103,
            width: challengeCardSize.width,
            height: challengeCardSize.height
        )
        
        rejectedLabel.sizeToFit()
        rejectedLabel.frame = CGRect(
            x: (view.width - rejectedLabel.width)/2,
            y: challengeCard.bottom + 15,
            width: rejectedLabel.width,
            height: rejectedLabel.height
        )
        
        if let text = infoLabel.text {
            let infoLabelBounds = text.boundingRect(
                with: CGSize(width: view.width - 66, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: infoLabel.font],
                context: nil
            )
            infoLabel.frame = CGRect(
                x: 33,
                y: rejectedLabel.bottom + 15,
                width: view.width - 66,
                height: infoLabelBounds.height
            )
        }
        
        backHomeButton.sizeToFit()
        backHomeButton.frame = CGRect(
            x: (view.width - backHomeButton.width)/2,
            y: view.height - 95,
            width: backHomeButton.width,
            height: backHomeButton.height
        )
    }

    @objc private func backHomeButtonTapped() {
        NavigationControlManager.backToHome()
    }
}
