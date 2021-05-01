//
//  EditImageView.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditProfileImageView: UIImageView {
    
    private let changeImageIcon = UIImageView(image: UIImage(systemName: "camera.fill"))

    init() {
        super.init(frame: .zero)
        
        changeImageIcon.tintColor = UIColor.white
        changeImageIcon.contentMode = .scaleAspectFill
        addSubview(changeImageIcon)
        
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = height/2
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "XYTint")!.cgColor
        
        let changeImageIconSize:CGFloat = 15
        changeImageIcon.frame = CGRect(
            x: (width - changeImageIconSize)/2,
            y: (height - changeImageIconSize)/2,
            width: changeImageIconSize,
            height: changeImageIconSize
        )
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.borderColor = UIColor(named: "XYTint")!.cgColor
    }
}
