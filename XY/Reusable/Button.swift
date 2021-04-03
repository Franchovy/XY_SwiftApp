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
    
    var shadowLayer = CALayer()
    
    init(image: UIImage? = nil, title: String? = nil, backgroundColor: UIColor? = nil, style: Style) {
        self.style = style
        
        super.init(frame: .zero)
        
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
        if let backgroundColor = backgroundColor {
            setBackgroundColor(color: backgroundColor, forState: .normal)
        }
        
        layer.sublayers?.forEach({ $0.masksToBounds = true })
        layer.insertSublayer(shadowLayer, at: 0)
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowOpacity = 0.7
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        
        if style == .circular {
            layer.cornerRadius = height/2
        }
    }

}
