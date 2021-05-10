//
//  VideoHeaderView.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit


class VideoHeaderView: UIView {

    private let titleLabel = Label(style: .title, fontSize: 31, adaptToLightMode: false)
    private let acceptButton = Button(title: "Accept", style: .colorButton(color: UIColor(0x03FF64), cornerRadius: 5), paddingVertical: 11.25, paddingHorizontal: 15)
    private let declineButton = Button(title: "Reject", style: .colorButton(color: UIColor(0xFB473D), cornerRadius: 5), paddingVertical: 11.25, paddingHorizontal: 15)
    
    var shouldDisplayAcceptDecline = true
    var acceptDeclineButtonsDisplayed = false
        
    var viewModel: ChallengeCardViewModel?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(acceptButton)
        addSubview(declineButton)
        addSubview(titleLabel)
        
        titleLabel.enableShadow = true
        
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
        
        declineButton.addTarget(self, action: #selector(tappedReject), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(tappedAccept), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (width - titleLabel.width)/2,
            y: 71.85,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        let buttonSize = CGSize(width: 90.5, height: 35)
        acceptButton.frame = CGRect(
            x: width/2 - buttonSize.width - 15.25,
            y: titleLabel.bottom + 25.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        declineButton.frame = CGRect(
            x: width/2 + 15.25,
            y: titleLabel.bottom + 25.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        let height = 71.85 + titleLabel.height + 35 + 25.75
        frame.size.height = height
        frame.size.width = 375
    }
    
    func appear(withDelay delay: Double) {
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
        
        acceptButton.transform = CGAffineTransform(translationX: 0, y: -34)
        declineButton.transform = CGAffineTransform(translationX: 0, y: -34)
        
        guard shouldDisplayAcceptDecline else { return }
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseIn) {
            self.acceptButton.transform = .identity
            self.declineButton.transform = .identity
            
            self.acceptButton.alpha = 1.0
            self.declineButton.alpha = 1.0

        } completion: { (done) in
            if done {
                self.acceptDeclineButtonsDisplayed = true
            }
        }

    }
    
    func configure(challengeViewModel: ChallengeCardViewModel) {
        shouldDisplayAcceptDecline = challengeViewModel.isReceived
        
        viewModel = challengeViewModel
        titleLabel.text = challengeViewModel.title
    }
    
    func hideButtons() {
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
    }

    @objc private func tappedAccept() {
        guard let viewModel = viewModel else {
            return
        }
        ChallengeDataManager.shared.updateChallengeState(challengeViewModel: viewModel, newState: .accepted)
        NavigationControlManager.startChallenge(with: viewModel)
    }
    
    @objc private func tappedReject() {
        let prompt = Prompt()
        prompt.setTitle(text: "Reject Challenge")
        prompt.addText(text: "Rejecting this challenge you’ll permanently lose the chance to perform it.")
        prompt.addCompletionButton(
            buttonText: "Reject",
            textColor: UIColor(0xEF3A30),
            style: .embedded,
            closeOnTap: true,
            onTap: {
                if let viewModel = self.viewModel {
                    ChallengeDataManager.shared.updateChallengeState(challengeViewModel: viewModel, newState: .rejected)
                    NavigationControlManager.mainViewController.navigationController?.pushViewController(RejectedChallengeViewController(viewModel: viewModel), animated: true)
                }
            }
        )
        prompt.addCompletionButton(
            buttonText: "Cancel",
            style: .embedded,
            closeOnTap: true
        )
        prompt.backgroundStyle = .fade
    
        NavigationControlManager.displayPrompt(prompt)
    }
}
