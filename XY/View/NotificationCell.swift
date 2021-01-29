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
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.alpha = 0.7
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "tintColor2")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        containerView.layer.shadowRadius = 1
        
        addSubview(containerView)
        
        let profileImageContainer = UIView()
        profileImageContainer.addSubview(profileImage)
        containerView.addSubview(profileImageContainer)
        
        let postImageContainer = UIView()
        postImageContainer.addSubview(postImage)
        containerView.addSubview(postImageContainer)
        
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
        
        if profileImage.image != nil {
            profileImage.superview!.frame = CGRect(
                x: 6,
                y: 12,
                width: 50,
                height: 50
            )
            profileImage.frame = profileImage.superview!.bounds
            profileImage.applyshadowWithCorner(
                containerView: profileImage.superview!,
                cornerRadious: profileImage.width / 2,
                shadowOffset: CGSize(width: 0, height: 3),
                shadowRadius: 6
            )
        }
        
        if postImage.image != nil {
            postImage.superview!.frame = CGRect(
                x: containerView.width - 50 - 10,
                y: 12,
                width: 50,
                height: 50
            )
            postImage.frame = postImage.superview!.bounds
            postImage.applyshadowWithCorner(
                containerView: postImage.superview!,
                cornerRadious: 10,
                shadowOffset: CGSize(width: 0, height: 3),
                shadowRadius: 6
            )
        }
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: profileImage.right + 15.28,
            y: 17.26,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        
        label.sizeToFit()
        label.frame = CGRect(
            x: profileImage.right + 15.28,
            y: nicknameLabel.bottom + 10.28,
            width: label.width,
            height: label.height
        )
        
        timestampLabel.sizeToFit()
        timestampLabel.frame = CGRect(
            x: label.right + 10,
            y: label.top + label.height/2 - timestampLabel.height/2,
            width: timestampLabel.width,
            height: timestampLabel.height
        )
    }

    func configure(with model: NotificationViewModel) {

        profileImage.image = model.displayImage
        postImage.image = model.previewImage
        nicknameLabel.text = model.nickname
        label.text = model.text
        timestampLabel.text = model.date.shortTimestamp()
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
        postImage.image = nil
        nicknameLabel.text = nil
        label.text = nil
        timestampLabel.text = nil
    }
}
