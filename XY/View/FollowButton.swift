//
//  FollowButton.swift
//  XY
//
//  Created by Maxime Franchot on 20/03/2021.
//

import UIKit
import FaveButton

class FollowButton: FaveButton {
    var relationshipType: RelationshipTypeForSelf?
    var otherUserID: String?

    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 11
        setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
        setTitleColor(.white, for: .normal)
        setBackgroundColor(color: .darkGray, forState: .disabled)
        setTitleColor(.lightGray, for: .disabled)
        setTitle("Follow", for: .normal)
        titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 16)
        layer.borderWidth = 0.7
        layer.borderColor = UIColor.white.cgColor
        
        addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(for relationshipType: RelationshipTypeForSelf, otherUserID: String) {
        self.relationshipType = relationshipType
        self.otherUserID = otherUserID
        
        updateButton()
    }
    
    private func updateButton() {
        guard let relationshipType = relationshipType else {
            return
        }
        
        switch relationshipType {
        case .following:
            setTitle("Subscribed", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            setBackgroundColor(color: .gray, forState: .normal)
            setAnimationsEnabled(enabled: false)
        case .follower:
            setTitle("Subscriber", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            setBackgroundColor(color: .gray, forState: .normal)
            setAnimationsEnabled(enabled: true)
        case .friends:
            setTitle("Friends", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 14)
            setBackgroundColor(color: UIColor(named: "XYpink")!, forState: .normal)
            setAnimationsEnabled(enabled: false)
        case .none:
            setTitle("Subscribe", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setAnimationsEnabled(enabled: true)
        }
    }
    
    @objc private func onPress() {
        guard let relationshipType = relationshipType,
              let otherUserID = otherUserID else {
            return
        }
        
        isEnabled = false
        
        HapticsManager.shared?.vibrate(for: .success)
        
        switch relationshipType {
        case .follower, .none:
            RelationshipFirestoreManager.shared.follow(otherId: otherUserID) { (relationshipModel) in
                if let relationshipModel = relationshipModel {
                    self.isEnabled = true
                    
                    self.relationshipType = relationshipModel.toRelationshipToSelfType()
                    self.updateButton()
                }
            }
        case .friends, .following:
            RelationshipFirestoreManager.shared.unfollow(otherId: otherUserID) { (result) in
                switch result {
                case .success(let relationshipModel):
                    self.isEnabled = true
                    
                    let type = relationshipModel?.toRelationshipToSelfType() ?? .none
                    self.relationshipType = type
                    self.updateButton()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
