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
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        label.textColor = .lightGray
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
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
//        let bubbleSize = CGSize(width: messageLabel.frame.width + 14,
//                                     height: messageLabel.frame.height + 26)
//
//        let bubbleWidth = bubbleSize.width
//        let bubbleHeight = bubbleSize.height
//
//        guard let senderIsSelf = viewModel?.senderIsSelf else {
//            return
//        }
//
//        if senderIsSelf {
//            chatBubbleView.frame = CGRect(x: width - bubbleWidth - 10,
//                                                y: 9,
//                                                width: bubbleWidth,
//                                                height: bubbleHeight)
//
//            chatBubbleView.backgroundColor = .lightGray
//
//        } else {
//            chatBubbleView.frame = CGRect(x: 10,
//                                    y: 9,
//                                    width: bubbleWidth,
//                                    height: bubbleHeight)
//            chatBubbleView.backgroundColor = .blue
//        }
//
//        messageLabel.frame = chatBubbleView.bounds.inset(by: UIEdgeInsets(top: 11, left: 7, bottom: 15, right: 7))
//
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 10,
            y: 1,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: chatBubbleView.width - timestampLabel.width - 6,
            y: chatBubbleView.height - timestampLabel.height - 1,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
    }
    
//    func setupMessage(text: String, outgoing: Bool) {
//
//        messageLabel.text = text
//
//        let constraintRect = CGSize(width: 0.66 * width,
//                                    height: .greatestFiniteMagnitude)
//        let boundingBox = text.boundingRect(with: constraintRect,
//                                            options: .usesLineFragmentOrigin,
//                                            attributes: [.font: messageLabel.font!],
//                                            context: nil)
//        messageLabel.frame.size = CGSize(width: ceil(boundingBox.width),
//                                  height: ceil(boundingBox.height))
//
//
//        setNeedsLayout()
//    }
    
    func setupMessage(text: String, outgoing: Bool) {
        
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

        let bubbleSize = CGSize(width: messageLabel.frame.width + 28,
                                     height: messageLabel.frame.height + 27)

        let bubbleWidth = bubbleSize.width
        let bubbleHeight = bubbleSize.height

        chatBubbleView.layer.cornerRadius = 15
        
        if outgoing {
            chatBubbleView.frame = CGRect(x: width - bubbleWidth - 25,
                                                y: 5,
                                                width: bubbleWidth,
                                                height: bubbleHeight)
            
            chatBubbleView.backgroundColor = .systemPink
            
        } else {
            chatBubbleView.frame = CGRect(x: 25,
                                    y: 5,
                                    width: bubbleWidth,
                                    height: bubbleHeight)
            chatBubbleView.backgroundColor = .blue
        }

        messageLabel.frame.origin = CGPoint(x: 12.5, y: 14.5)
    }
    
    public func configure(with viewModel: MessageViewModel) {
        print("Configuring message: \(viewModel)")
        nameLabel.text = viewModel.nickname
        timestampLabel.text = viewModel.timestamp.shortTimestamp()
        setupMessage(text: viewModel.text, outgoing: viewModel.senderIsSelf)
        
        self.viewModel = viewModel
    }
}
