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
    
    var borderGradientLayer: CAGradientLayer?

    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 11
        setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
        setTitleColor(.white, for: .normal)
        setBackgroundColor(color: .darkGray, forState: .disabled)
        setTitleColor(.lightGray, for: .disabled)
        setTitle("Follow", for: .normal)
        titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 16)
        
        addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderGradientLayer?.frame = bounds
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: height/2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
//        borderGradientLayer?.mask = shape
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
            setBackgroundColor(color: .clear, forState: .normal)
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 1
            setAnimationsEnabled(enabled: false)
        case .follower:
            setTitle("Subscriber", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            setBackgroundColor(color: .gray, forState: .normal)
            setAnimationsEnabled(enabled: true)
            resetBorder()
        case .friends:
            setTitle("Friends", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 14)
            setBackgroundColor(color: .clear, forState: .normal)
            resetBorder()
            setBorderGradient()
            setAnimationsEnabled(enabled: false)
        case .none:
            setTitle("Subscribe", for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 12)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setAnimationsEnabled(enabled: true)
            resetBorder()
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
    
    private func resetBorder() {
        borderGradientLayer?.removeFromSuperlayer()
        
        layer.borderWidth = 0
    }
    
    private func setBorderGradient() {
        let borderGradientLayer = CAGradientLayer()
        borderGradientLayer.colors = Global.xyGradient.map({$0.cgColor})
        borderGradientLayer.startPoint = CGPoint(x: 0, y: 0.7)
        borderGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.3)
        borderGradientLayer.locations = [0.3, 0.7]
        
        borderGradientLayer.frame = bounds
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: height/2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        borderGradientLayer.mask = shape
        
        layer.addSublayer(borderGradientLayer)
        
        self.borderGradientLayer = borderGradientLayer
    }
}
