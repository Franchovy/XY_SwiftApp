//
//  FriendBubble.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class FriendBubble: UIView {

    let imageView = UIImageView()
    let shadowLayer = CALayer()
    
    var emptyImage:Bool = true
    
    init() {
        super.init(frame: .zero)
        
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        
        layer.insertSublayer(shadowLayer, at: 0)
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        shadowLayer.frame = bounds
        
        imageView.frame = bounds
        imageView.layer.cornerRadius = height/2
    }
    
    public func prepareForReuse() {
        emptyImage = true
        imageView.layer.borderWidth = 0
        imageView.image = nil
        shadowLayer.opacity = 1.0
    }
    
    public func configure(with viewModel: UserViewModel) {
        if viewModel.profileImage != nil {
            imageView.image = viewModel.profileImage
            emptyImage = false
        } else {
            emptyImage = true
            
            imageView.image = UIImage(systemName: "person.fill")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
            
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.white.cgColor
            shadowLayer.opacity = 0.0
        }
    }
}
