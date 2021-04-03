//
//  Button.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class Button: UIButton {

    enum Style {
        case circular
    }
    var style: Style
    
    var backgroundLayer = CALayer()
    
    init(image: UIImage? = nil, title: String? = nil, backgroundColor: UIColor? = nil, style: Style) {
        self.style = style
        
        super.init(frame: .zero)
        
        setImage(image, for: .normal)
        tintColor = UIColor(named: "XYWhite")
        
        setTitle(title, for: .normal)
        
        if let backgroundColor = backgroundColor {
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        }
        
        backgroundLayer.masksToBounds = true
    
        layer.insertSublayer(backgroundLayer, below: imageView?.layer)
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.7
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        
        if style == .circular {
            backgroundLayer.cornerRadius = height/2
        }
    }
}
