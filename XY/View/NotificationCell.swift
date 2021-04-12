//
//  NotificationCell.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import UIKit

protocol NotificationCellDelegate {
    func pushPostViewController(_ vc: PostViewController)
}

class NotificationCell: UITableViewCell {

    static let identifier = "NotificationCell"
    var viewModel: _NotificationViewModel?
    
    private let profileImageContainer = UIView()
    public let profileImage: UIButton = {
        let imageView = UIButton()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35 / 2
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let postImageContainer = UIView()
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
    
    
    var delegate: NotificationCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        containerView.layer.shadowRadius = 1
        
        addSubview(containerView)
        
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none
        
        profileImageContainer.addSubview(profileImage)
        containerView.addSubview(profileImageContainer)
        
        postImageContainer.addSubview(postImage)
        containerView.addSubview(postImageContainer)
        
        containerView.addSubview(nicknameLabel)
        containerView.addSubview(label)
        containerView.addSubview(timestampLabel)
        
        profileImage.addTarget(self, action: #selector(profilePictureTapped), for: .touchUpInside)
        
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
        
        if profileImage.backgroundImage(for: .normal) != nil {
            
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
            
            profileImageContainer.layer.shadowOpacity = 1.0
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
            
            postImageContainer.layer.shadowOpacity = 1.0
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
            x: profileImage.backgroundImage(for: .normal) == nil ? 15 : profileImage.right + 15.28 ,
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
    
    @objc func profilePictureTapped() {
        guard let profileId = viewModel?.profileData?.profileId else {
            return
        }
        _ProfileManager.shared.openProfileForId(profileId)
    }
    
    @objc func postTapped() {
        guard let postData = viewModel?.postData else {
            return
        }
        
        let originalTransform = postImage.transform
        let shrinkTransform = postImage.transform.scaledBy(x: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.2) {
            self.postImage.transform = shrinkTransform
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2) {
                    self.postImage.transform = originalTransform
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.postImage.heroID = "post"
            
            let vc = PostViewController()
            
            PostViewModelBuilder.build(from: postData) { (postViewModel) in
                if let postViewModel = postViewModel {
                    vc.configure(with: postViewModel)
                }
            }
            
            vc.isHeroEnabled = true
            
            vc.onDismiss = { self.postImage.heroID = "" }
            
            vc.setHeroIDs(forPost: "post", forCaption: "", forImage: "")
            
            self.delegate?.pushPostViewController(vc)
        }
        
    }
    
    public func loadPostData(postModel: PostModel) {
        // Load XP Data
        
    }

    func configure(with model: _NotificationViewModel) {
        profileImage.setBackgroundImage(model.displayImage, for: .normal)
        postImage.image = model.previewImage
        nicknameLabel.text = model.nickname
        label.text = model.text
        timestampLabel.text = model.date.shortTimestamp()
        
        self.viewModel = model
    }
    
    override func prepareForReuse() {
        profileImage.setBackgroundImage(nil, for: .normal)
        postImage.image = nil
        
        profileImageContainer.layer.shadowOpacity = 0.0
        postImageContainer.layer.shadowOpacity = 0.0
        
        nicknameLabel.text = nil
        label.text = nil
        timestampLabel.text = nil
        
        self.viewModel = nil
    }
}

