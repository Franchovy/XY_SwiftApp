//
//  ChallengeNotificationImage.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class ChallengeNotificationImage: UIView {

    private let shadowLayer = CALayer()
    private let challengeImageView = UIImageView()
    private var iconImageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1.0
        
        challengeImageView.contentMode = .scaleAspectFill
        challengeImageView.layer.cornerRadius = 3
        challengeImageView.layer.masksToBounds = true
        
        layer.insertSublayer(shadowLayer, at: 0)
        addSubview(challengeImageView)
        addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.frame = bounds
        challengeImageView.frame = bounds
    
        iconImageView.frame = CGRect(
            x: 10,
            y: 10,
            width: width - 20,
            height: height - 20
        )
    }
    
    public func setImage(_ image: UIImage) {
        challengeImageView.image = image
    }
    
    public func reset() {
        challengeImageView.alpha = 1.0
        iconImageView.image = nil
    }
    
    enum IconType {
        case xmark
        case check
    }
    
    public func setIcon(_ iconType: IconType) {
        switch iconType {
        case .check:
            iconImageView.image = UIImage(systemName: "checkmark")!.withTintColor(UIColor(0x21FF7F), renderingMode: .alwaysOriginal)
        case .xmark:
            iconImageView.image = UIImage(systemName: "xmark")!.withTintColor(UIColor(0xEE3A30), renderingMode: .alwaysOriginal)
        }
        
        challengeImageView.alpha = 0.5
    }
}
