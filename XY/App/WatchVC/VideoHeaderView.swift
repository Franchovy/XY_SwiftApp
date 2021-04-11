//
//  VideoHeaderView.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit

class VideoHeaderView: UIView {

    private let titleLabel = Label(style: .title, fontSize: 26)
    private let acceptButton = Button(title: "Accept", style: .colorButton(color: UIColor(0x03FF64), cornerRadius: 5), paddingVertical: 7.25, paddingHorizontal: 12)
    private let declineButton = Button(title: "Reject", style: .colorButton(color: UIColor(0xFB473D), cornerRadius: 5), paddingVertical: 7.25, paddingHorizontal: 12)
    
    var acceptDeclineButtonsDisplayed = false
        
    var viewModel: ChallengeCardViewModel?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(acceptButton)
        addSubview(declineButton)
        
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
            y: 41.85,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        let buttonSize = CGSize(width: 63.5, height: 24)
        acceptButton.frame = CGRect(
            x: width/2 - buttonSize.width - 10.25,
            y: titleLabel.bottom + 8.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        declineButton.frame = CGRect(
            x: width/2 + 10.25,
            y: titleLabel.bottom + 8.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        var height = 41.85 + titleLabel.height + 63.5 + 8.75 + 63.5 + 8.75
        frame.size.height = height
        frame.size.width = superview?.width ?? 375
    }
    
    func appear() {
        acceptButton.transform = CGAffineTransform(translationX: 0, y: -70)
        declineButton.transform = CGAffineTransform(translationX: 0, y: -70)
        
        UIView.animate(withDuration: 0.3, delay: 5.0, options: .curveEaseIn) {
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
        viewModel = challengeViewModel
        titleLabel.text = challengeViewModel.title
    }

    @objc private func tappedAccept() {
        
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
