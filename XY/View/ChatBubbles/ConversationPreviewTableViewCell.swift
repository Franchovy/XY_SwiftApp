//
//  ConversationPreviewTableViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import UIKit

class ConversationPreviewTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationPreviewTableViewCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let previewMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
        addSubview(previewMessageLabel)
        addSubview(timestampLabel)
        addSubview(profileImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.frame = CGRect(
            x: 5,
            y: 21,
            width: 50,
            height: 50
        )
        profileImageView.layer.cornerRadius = 50 / 2
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: profileImageView.right + 16.46,
            y: height/2 - 5 - nameLabel.height,
            width: 250,
            height: nameLabel.height
        )
        
        previewMessageLabel.frame = CGRect(
            x: profileImageView.right + 16.46,
            y: height/2 + 10,
            width: 250,
            height: 25
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: width - timestampLabel.width - 7,
            y: 6,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
    }
    
    func configure(with viewModel: ConversationViewModel) {
        profileImageView.image = viewModel.image
        nameLabel.text = viewModel.name
        previewMessageLabel.text = viewModel.lastMessageText
        timestampLabel.text = viewModel.lastMessageTimestamp.shortTimestamp()
    }
    
}
