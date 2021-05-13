//
//  VideoHeaderView.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit


protocol VideoHeaderViewDelegate: class {
    func pressedAccept(viewModel: ChallengeCardViewModel)
    func pressedReject(viewModel: ChallengeCardViewModel)
    func pressedPlay(viewModel: ChallengeCardViewModel)
}

class VideoHeaderView: UIView {

    private let titleLabel = Label(style: .title, fontSize: 31, adaptToLightMode: false)
    private let acceptButton = Button(title: "Accept", style: .colorButton(color: UIColor(0x03FF64), cornerRadius: 5), paddingVertical: 11.25, paddingHorizontal: 15)
    private let declineButton = Button(title: "Reject", style: .colorButton(color: UIColor(0xFB473D), cornerRadius: 5), paddingVertical: 11.25, paddingHorizontal: 15)
    private let playButton = Button(title: "Play", style: .colorButton(color: UIColor(0x03FF64), cornerRadius: 5), paddingVertical: 11.25, paddingHorizontal: 15)
    
    var shouldDisplayPlay = false
    var shouldDisplayAcceptDecline = true
    var buttonsDisplayed = false
    
    weak var delegate: VideoHeaderViewDelegate?
    
    var viewModel: ChallengeCardViewModel?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(acceptButton)
        addSubview(declineButton)
        addSubview(titleLabel)
        addSubview(playButton)
        
        titleLabel.enableShadow = true
        
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
        playButton.alpha = 0.0
        
        declineButton.addTarget(self, action: #selector(tappedReject), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(tappedAccept), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(tappedPlay), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (width - titleLabel.width)/2,
            y: 46.85,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        
        let buttonSize = CGSize(width: 90.5, height: 35)
        acceptButton.frame = CGRect(
            x: width/2 - buttonSize.width - 15.25,
            y: titleLabel.bottom + 15.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        declineButton.frame = CGRect(
            x: width/2 + 15.25,
            y: titleLabel.bottom + 15.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
    
        playButton.frame = CGRect(
            x: (width - buttonSize.width)/2,
            y: titleLabel.bottom + 15.75,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        let height = 46.85 + titleLabel.height + 15.75 + 35
        frame.size.height = height
        frame.size.width = 375
    }
    
    func appear(withDelay delay: Double) {
        
        
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
        playButton.alpha = 0.0
        
        acceptButton.transform = CGAffineTransform(translationX: 0, y: -34)
        declineButton.transform = CGAffineTransform(translationX: 0, y: -34)
        playButton.transform = CGAffineTransform(translationX: 0, y: -34)
        
        
        
        if shouldDisplayAcceptDecline {
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseIn) {
                self.acceptButton.transform = .identity
                self.declineButton.transform = .identity
                
                self.acceptButton.alpha = 1.0
                self.declineButton.alpha = 1.0

            } completion: { (done) in
                if done {
                    self.buttonsDisplayed = true
                }
            }
        } else if shouldDisplayPlay {
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseIn) {
                self.playButton.transform = .identity
                
                self.playButton.alpha = 1.0
            } completion: { (done) in
                if done {
                    self.buttonsDisplayed = true
                }
            }
        }
    }
    
    func configure(challengeViewModel: ChallengeCardViewModel) {
        shouldDisplayAcceptDecline = challengeViewModel.isReceived && challengeViewModel.completionState == .received
        shouldDisplayPlay = challengeViewModel.completionState == .accepted
        
        viewModel = challengeViewModel
        titleLabel.text = challengeViewModel.title
    }
    
    func hideButtons() {
        
    }

    @objc private func tappedPlay() {
        guard let viewModel = viewModel else {
            return
        }
        
        delegate?.pressedPlay(viewModel: viewModel)
        hideButtons()
    }
    
    @objc private func tappedAccept() {
        guard let viewModel = viewModel else {
            return
        }
        
        delegate?.pressedAccept(viewModel: viewModel)
        hideButtons()
    }
    
    @objc private func tappedReject() {
        guard let viewModel = viewModel else {
            return
        }
        
        delegate?.pressedReject(viewModel: viewModel)
        hideButtons()
    }
}
