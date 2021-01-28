//
//  NotificationCell.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import UIKit

//TODO: Delegate for data fetch

class NotificationCell: UITableViewCell {

    static let identifier = "NotificationCell"
    
    public let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35 / 2
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public let postImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35 / 2
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        return label
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor")
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor")
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 10)
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Black")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        containerView.layer.shadowRadius = 1
        
        addSubview(containerView)
        containerView.addSubview(profileImage)
        containerView.addSubview(postImage)
        containerView.addSubview(nicknameLabel)
        containerView.addSubview(label)
        containerView.addSubview(timestampLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        
        containerView.frame = CGRect(
            x: 15,
            y: 5,
            width: contentView.width - 30,
            height: contentView.height - 5
        )
        
        profileImage.frame = CGRect(
            x: 5,
            y: 21,
            width: 35,
            height: 35
        )
        
        profileImage.layer.cornerRadius = profileImage.width / 2
        profileImage.layer.shadowOffset = CGSize(width: 0, height: 3)
        profileImage.layer.shadowRadius = 6
        
        postImage.frame = CGRect(
            x: containerView.width - 50 - 10,
            y: 12,
            width: 50,
            height: 50
        )
        
        postImage.layer.cornerRadius = 10
        postImage.layer.shadowOffset = CGSize(width: 0, height: 3)
        postImage.layer.shadowRadius = 6
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: profileImage.right + 10,
            y: 14,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        
        label.sizeToFit()
        label.frame = CGRect(
            x: profileImage.right + 10,
            y: nicknameLabel.bottom + 10,
            width: label.width,
            height: label.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: postImage.right - timestampLabel.width - 15,
            y: postImage.bottom,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
    }

    func configure(with model: NotificationViewModel) {

        profileImage.image = model.displayImage
        postImage.image = model.previewImage
        nicknameLabel.text = model.nickname
        label.text = model.text
        timestampLabel.text = DateFormatter.defaultFormatter.string(from: model.date)
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
        postImage.image = nil
        nicknameLabel.text = nil
        label.text = nil
        timestampLabel.text = nil
    }
}
