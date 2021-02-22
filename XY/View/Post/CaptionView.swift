//
//  CaptionView.swift
//  XY
//
//  Created by Maxime Franchot on 22/02/2021.
//

import UIKit

class CaptionView: UIView {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = .white
        label.alpha = 1
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 14)
        label.textColor = .white
        label.alpha = 0.5
        return label
    }()
    
    private var viewModel: CommentViewModel?
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 15
        
        addSubview(messageLabel)
        addSubview(nameLabel)
        addSubview(timestampLabel)
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 10,
            y: 4,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: width - timestampLabel.width - 10,
            y: 4,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
    }
    
    func setupMessage(text: String) {
        
        messageLabel.numberOfLines = 0
        messageLabel.text = text
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: messageLabel.font],
                                            context: nil)
        messageLabel.frame.size = CGSize(width: ceil(boundingBox.width),
                                         height: ceil(boundingBox.height))
        messageLabel.frame.origin = CGPoint(x: 12, y: 31)
    }
    
    public func configure(withText: String, name: String, timestamp: String, colour: UIColor) {
        backgroundColor = colour
    }
    
    public func getText() -> String {
        return messageLabel.text ?? ""
    }
    
    var editing = false
    
    public func toggleInputMode(inputMode: Bool) {
        editing = inputMode
    }

    public func isEditing() -> Bool {
        return editing
    }
}
