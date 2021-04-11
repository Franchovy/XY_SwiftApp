//
//  VideoHeaderView.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit

class VideoHeaderView: UIView {

    private let titleLabel = Label(style: .title, fontSize: 26)
    private let acceptButton = Button(title: "Accept", style: .colorButton(color: UIColor(0x03FF64), cornerRadius: 5), paddingVertical: 3.25, paddingHorizontal: 6)
    private let declineButton = Button(title: "Reject", style: .colorButton(color: UIColor(0xFB473D), cornerRadius: 5), paddingVertical: 3.25, paddingHorizontal: 6)
    
    var acceptDeclineButtonsDisplayed = false
    
    init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(acceptButton)
        addSubview(declineButton)
        
        acceptButton.alpha = 0.0
        declineButton.alpha = 0.0
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
    
    func configure(challengeName: String) {
        titleLabel.text = challengeName
    }

}
