//
//  ProfileBubble.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import UIKit
import FaveButton

protocol ProfileBubbleDelegate {
    func plusButtonPressed()
}

class ProfileBubble: UIView {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = .gray
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let followButton: FaveButton = {
        let button = FaveButton(
            frame: .zero,
            faveIconNormal: UIImage()
        )
        button.layer.cornerRadius = 11
        button.setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: .darkGray, forState: .disabled)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle("Follow", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 16)
        button.layer.borderWidth = 0.7
        button.layer.borderColor = UIColor.white.cgColor
        button.isHidden = true
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 11
        button.backgroundColor = UIColor(0x007BF5)
        button.setImage(UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.layer.borderWidth = 0.7
        button.layer.borderColor = UIColor.white.cgColor
        button.isHidden = true
        return button
    }()
    
    var delegate: ProfileBubbleDelegate?
    var viewModel: NewProfileViewModel?
    
    enum FollowButtonPos {
        case forProfile
        case forVideo
    }
    var followButtonPos: FollowButtonPos = .forProfile
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        addSubview(profileImageView)
        addSubview(followButton)
        addSubview(addButton)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.68
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        
        followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: 60,
            height: 60
        )
        profileImageView.layer.cornerRadius = 30
        
        followButton.frame = CGRect(
            x: followButtonPos == .forProfile ? 38 : -5,
            y: followButtonPos == .forProfile ? -6 : 57,
            width: 72,
            height: 23
        )
        
        addButton.frame = CGRect(
            x: 38,
            y: -11.5,
            width: 24,
            height: 24
        )
        addButton.layer.cornerRadius = 12
    }
    
    public func configure(with viewModel: NewProfileViewModel, followButtonPos: FollowButtonPos = .forProfile) {
        self.viewModel = viewModel
        self.followButtonPos = followButtonPos
        
        if followButtonPos == .forVideo, viewModel.userId != AuthManager.shared.userId ?? "" {
            setButtonMode(mode: .follow)
        }
        
        setNeedsLayout()
        
        profileImageView.image = viewModel.profileImage
        
        updateFollowButton(for: viewModel.relationshipType)
    }
    
    public func setHeroID(id: String) {
        profileImageView.heroID = id
    }
    
    enum ButtonMode {
        case follow
        case add
    }
    
    public func setButtonMode(mode: ButtonMode) {
        switch mode {
        case .follow:
            followButton.isHidden = false
        case .add:
            addButton.isHidden = false
        }
    }
    
    @objc private func followButtonPressed() {
        guard let viewModel = viewModel else {
            return
        }
        followButton.isEnabled = false
        
        HapticsManager.shared?.vibrate(for: .success)
        
        switch viewModel.relationshipType {
        case .follower, .none:
            RelationshipFirestoreManager.shared.follow(otherId: viewModel.userId) { (relationshipModel) in
                if let relationshipModel = relationshipModel {
                    self.followButton.isEnabled = true
                    self.viewModel?.relationshipType = relationshipModel.toRelationshipToSelfType()
                    
                    self.updateFollowButton(for: relationshipModel.toRelationshipToSelfType())
                }
            }
        case .friends, .following:
            RelationshipFirestoreManager.shared.unfollow(otherId: viewModel.userId) { (result) in
                switch result {
                case .success(let relationshipModel):
                    self.followButton.isEnabled = true
                    
                    let type = relationshipModel?.toRelationshipToSelfType() ?? .none
                    self.viewModel?.relationshipType = type
                    
                    self.updateFollowButton(for: type)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc private func addButtonPressed() {
        delegate?.plusButtonPressed()
    }
    
    private func updateFollowButton(for relationshipType: RelationshipTypeForSelf) {
        switch relationshipType {
        case .following:
            followButton.setTitle("Following", for: .normal)
            followButton.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 14)
            followButton.setBackgroundColor(color: .gray, forState: .normal)
            followButton.setAnimationsEnabled(enabled: false)
        case .follower:
            followButton.setTitle("Follow back", for: .normal)
            followButton.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            followButton.setBackgroundColor(color: .gray, forState: .normal)
            followButton.setAnimationsEnabled(enabled: true)
        case .friends:
            followButton.setTitle("Friends", for: .normal)
            followButton.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 16)
            followButton.setBackgroundColor(color: UIColor(named: "XYpink")!, forState: .normal)
            followButton.setAnimationsEnabled(enabled: false)
        case .none:
            followButton.setTitle("Follow", for: .normal)
            followButton.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 16)
            followButton.setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            followButton.setAnimationsEnabled(enabled: true)
        }
    }
}
