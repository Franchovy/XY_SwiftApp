//
//  SentChallengeVideoFooterView.swift
//  XY
//
//  Created by Maxime Franchot on 29/04/2021.
//

import UIKit

class SentChallengeVideoFooterView: UIView {
    
    private var friendBubbles = [FriendBubble]()
    private let youChallengedLabel = Label("You challenged", style: .title, fontSize: 20, adaptToLightMode: false)
    private let moreFriendsLabel = Label(style: .info, fontSize: 10, adaptToLightMode: false)
    private let descriptionLabel = Label(style: .info, fontSize: 15, adaptToLightMode: false)
    
    init() {
        super.init(frame: .zero)
        
        addSubview(youChallengedLabel)
        addSubview(moreFriendsLabel)
        addSubview(descriptionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let descriptionLabelBoundingRect = descriptionLabel.text!.boundingRect(
            with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionLabel.font],
            context: nil
        )
        descriptionLabel.frame = CGRect(
            x: 10,
            y: height - descriptionLabelBoundingRect.height - 19.5,
            width: width - 20,
            height: descriptionLabelBoundingRect.height
        )
        
        youChallengedLabel.sizeToFit()
        youChallengedLabel.frame = CGRect(
            x: 11,
            y: descriptionLabel.top - 14.5 - youChallengedLabel.height,
            width: youChallengedLabel.width,
            height: youChallengedLabel.height
        )
        
        var friendBubbleX = youChallengedLabel.right + 11
        for friendBubble in friendBubbles {
            friendBubble.frame = CGRect(
                x: friendBubbleX,
                y: youChallengedLabel.center.y - 20,
                width: 40,
                height: 40
            )
            
            friendBubbleX += 25
        }
        
        moreFriendsLabel.sizeToFit()
        moreFriendsLabel.frame = CGRect(
            x: friendBubbleX + 40 + 5,
            y: youChallengedLabel.center.y - moreFriendsLabel.height/2,
            width: moreFriendsLabel.width,
            height: moreFriendsLabel.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        var height:CGFloat = 27
        
        if let text = descriptionLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 20, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: descriptionLabel.font],
                context: nil
            )
            height += boundingRect.height
        }
        
        height += 40 + 6.5
        
        frame.size.height = height
        frame.size.width = 375
    }
    
    public func configure(with viewModel: ChallengeCardViewModel) {
        if let userViewModels = viewModel.friendBubbles {
            for userViewModel in userViewModels {
                if friendBubbles.count > 3 {
                    break
                }
                
                let friendBubble = FriendBubble()
                friendBubble.configure(with: userViewModel)
                addSubview(friendBubble)
                friendBubbles.append(friendBubble)
            }
            
            let numExtraFriendsChallenged = friendBubbles.count - 3
            if numExtraFriendsChallenged > 0 {
                moreFriendsLabel.text = "+ \(numExtraFriendsChallenged) more"
            }
        }
        
        descriptionLabel.text = viewModel.description
    }
    
}
