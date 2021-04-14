//
//  VideoFooterView.swift
//  XY
//
//  Created by Maxime Franchot on 11/04/2021.
//

import UIKit

class VideoFooterView: UIView {

    private let profileBubble = FriendBubble()
    private let challengedYouLabel = Label(style: .title, fontSize: 15, adaptToLightMode: false)
    private let challengeDescriptionLabel = Label(style: .body, fontSize: 12, adaptToLightMode: false)
    
    init() {
        super.init(frame: .zero)
        
        addSubview(profileBubble)
        addSubview(challengedYouLabel)
        addSubview(challengeDescriptionLabel)
        
        challengedYouLabel.enableShadow = true
        challengeDescriptionLabel.enableShadow = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let text = challengeDescriptionLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: challengeDescriptionLabel.font],
                context: nil
            )
            
            challengeDescriptionLabel.frame = CGRect(
                x: 10,
                y: height - 27 - boundingRect.height,
                width: width - 20,
                height: boundingRect.height
            )
        }
        
        if let text = challengedYouLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font : challengedYouLabel.font],
                context: nil
            )
            
            challengedYouLabel.frame = CGRect(
                x: 10,
                y: challengeDescriptionLabel.top - boundingRect.height - 1,
                width: width - 20,
                height: boundingRect.height
            )
        }
        
        let profileBubbleSize:CGFloat = 70
        profileBubble.frame = CGRect(
            x: 10,
            y: challengedYouLabel.top - 5 - profileBubbleSize,
            width: profileBubbleSize,
            height: profileBubbleSize
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        var height:CGFloat = 27
        
        if let text = challengeDescriptionLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: challengeDescriptionLabel.font],
                context: nil
            )
            height += boundingRect.height
        }
        
        if let text = challengedYouLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font : challengedYouLabel.font],
                context: nil
            )
            
            height += boundingRect.height + 20
        }
        
        height += 70 + 5
        
        frame.size.height = height
        frame.size.width = 375
    }
    
    func configure(profileViewModel: FriendBubbleViewModel, challengeViewModel: ChallengeCardViewModel) {
        profileBubble.setImage(profileViewModel.image)
        challengedYouLabel.text = "\(profileViewModel.nickname) challenged you to:"
        challengeDescriptionLabel.text = challengeViewModel.description
    }
}
