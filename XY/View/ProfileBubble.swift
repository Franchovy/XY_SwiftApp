//
//  ProfileBubble.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import UIKit
import FaveButton

class ProfileBubble: UIView {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = .gray
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
            x: 38,
            y: -6,
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
    
    public func configure(with viewModel: ProfileViewModel) {
        profileImageView.image = viewModel.profileImage
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
}
