//
//  TextField.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class TextField: UITextField {
    
    let shadowLayer = CALayer()
    let maxCharsLabel: UILabel?

    init(placeholder: String? = nil, style: Style = .card, maxChars: Int? = nil) {
        maxCharsLabel = UILabel()
        maxCharsLabel!.text = "0/\(maxChars)"
        
        super.init(frame: .zero)
        
        if let placeholder = placeholder {
            self.placeholder = placeholder
        }
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowOpacity = 0.8
        
        layer.insertSublayer(shadowLayer, at: 0)
        
        setStyle(style)
        
        font = UIFont(name: "Raleway-Medium", size: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.frame = bounds
    }
    
    enum Style {
        case clear
        case card
    }
    
    public func setStyle(_ style: Style) {
        switch style {
        case .clear:
            shadowLayer.isHidden = true
        case .card:
            layer.cornerRadius = 15
            layer.sublayers?.filter({$0 != shadowLayer}).forEach({$0.masksToBounds = true})
            backgroundColor = UIColor(named: "XYCard")
            textColor = UIColor(named: "XYTint")
        }
    }
        
    var inset: CGFloat = 10

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

}
