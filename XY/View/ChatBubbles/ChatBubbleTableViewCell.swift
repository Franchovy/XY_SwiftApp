//
//  ChatBubbleTableViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

class ChatBubbleTableViewCell: UITableViewCell {
    
    static let identifier = "ChatBubbleTableViewCell"

    private let chatBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 14)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 10)
        label.textColor = .white
        label.alpha = 0.9
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 12)
        label.textColor = .white
        return label
    }()
    
    private var viewModel: MessageViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(chatBubbleView)
        chatBubbleView.addSubview(messageLabel)
        chatBubbleView.addSubview(nameLabel)
        chatBubbleView.addSubview(timestampLabel)
        
        chatBubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        chatBubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 10,
            y: 1,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: chatBubbleView.width - timestampLabel.width - 10,
            y: chatBubbleView.height - timestampLabel.height - 1,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
        
        layoutChatBubble()
    }
    
    func setupMessage(text: String) {
        
        messageLabel.numberOfLines = 0
        messageLabel.text = text

        let constraintRect = CGSize(width: 0.66 * width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: messageLabel.font],
                                            context: nil)
        messageLabel.frame.size = CGSize(width: ceil(boundingBox.width),
                                  height: ceil(boundingBox.height))


        layoutChatBubble()
    }
    
    private func layoutChatBubble() {
        let bubbleSize = CGSize(width: messageLabel.frame.width + 28,
                                     height: messageLabel.frame.height + 27)

        let bubbleWidth = bubbleSize.width
        let bubbleHeight = bubbleSize.height

        chatBubbleView.layer.cornerRadius = 15
        
        guard let outgoing = viewModel?.senderIsSelf else {
            return
        }
        
        if outgoing {
            chatBubbleView.frame = CGRect(x: width - bubbleWidth - 21,
                                                y: 5,
                                                width: bubbleWidth,
                                                height: bubbleHeight)
            
            chatBubbleView.backgroundColor = UIColor(named: "XYpink")
            
        } else {
            chatBubbleView.frame = CGRect(x: 21,
                                    y: 5,
                                    width: bubbleWidth,
                                    height: bubbleHeight)
            chatBubbleView.backgroundColor = .XYBlue
        }

        messageLabel.frame.origin = CGPoint(x: 12.5, y: 14.5)
    }
    
    public func configure(with viewModel: MessageViewModel) {
        nameLabel.text = viewModel.nickname
        timestampLabel.text = viewModel.timestamp.shortTimestamp()
        
        self.viewModel = viewModel
        setupMessage(text: viewModel.text)
    }
}
