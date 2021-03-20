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
    
    private let followButton = FollowButton()
    
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
        
        followButton.isHidden = true
        
        addSubview(profileImageView)
        addSubview(followButton)
        addSubview(addButton)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.68
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        
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
        
        followButton.configure(for: viewModel.relationshipType, otherUserID: viewModel.userId)
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
    
    @objc private func addButtonPressed() {
        delegate?.plusButtonPressed()
    }
}
