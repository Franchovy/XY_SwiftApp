//
//  AddFriendButton.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class AddFriendButton: UIButton, FriendsDataManagerListener {

    init() {
        super.init(frame: .zero)
        
        titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 12)
        
        titleEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: titleLabel!.heightAnchor, constant: 16).isActive = true
        widthAnchor.constraint(equalTo: titleLabel!.widthAnchor, constant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        FriendsDataManager.shared.deregisterChangeListener(listener: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = height/2
    }
    
    var viewModel: UserViewModel?
    var status: FriendStatus = .none
    
    public func configure(with viewModel: UserViewModel) {
        isHidden = false
        layer.borderWidth = 0
        
        self.viewModel = viewModel
        self.status = viewModel.friendStatus
        
        if viewModel.nickname == ProfileDataManager.shared.nickname {
            isHidden = true
            return
        } else {
            setupButtonForCurrentStatus()
            
            FriendsDataManager.shared.registerChangeListener(for: viewModel, listener: self)
        }
    }
    
    public func prepareForReuse() {
        isHidden = true
        viewModel = nil
        layer.borderWidth = 0
        status = .none
        FriendsDataManager.shared.deregisterChangeListener(listener: self)
    }
    
    func didUpdateFriendshipState(to state: FriendStatus) {
        status = state
        setupButtonForCurrentStatus()
    }
    
    func didUpdateProfileImage(to image: UIImage) {
        
    }
    
    private func changeStateTapped() {
        switch status {
        case .none:
            status = .added
        case .addedMe:
            status = .friend
        case .added:
            status = .none
        case .friend:
            status = .addedMe
        }
        
        setupButtonForCurrentStatus()
    }
    
    private func setupButtonForCurrentStatus() {
        switch status {
        case .none:
            setTitle("Add", for: .normal)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
        case .addedMe:
            setTitle("Add back", for: .normal)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
        case .friend:
            setTitle("Friend", for: .normal)
            setBackgroundColor(color: UIColor(0xFF0062), forState: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
        case .added:
            setTitle("Added", for: .normal)
            setBackgroundColor(color: UIColor.clear, forState: .normal)
            setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "XYTint")!.cgColor
        }
        
        titleLabel!.sizeToFit()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.borderColor = UIColor(named: "XYTint")!.cgColor
        
        if status == .added {
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        switch status {
        case .added, .friend:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { (done) in
                if done {
                    self.changeStateTapped()
                    
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) {
                        self.transform = .identity
                    } completion: { (done) in
                        if done {
                            self.updateFriendDataForButtonPressed()
                        }
                    }
                }
            }
        default:
            HapticsManager.shared.vibrateImpact(for: .heavy)
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) {
                self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            } completion: { (done) in
                if done {
                    self.changeStateTapped()
                    
                    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 5.0, options: .curveEaseIn) {
                        self.transform = .identity
                    } completion: { (done) in
                        if done {
                            self.updateFriendDataForButtonPressed()
                        }
                    }

                }
            }
        }
    }
    
    func updateFriendDataForButtonPressed() {
        guard let viewModel = viewModel else {
            return
        }
        FriendsDataManager.shared.updateFriendStatus(friend: self.viewModel!, newStatus: status)
    }
}
