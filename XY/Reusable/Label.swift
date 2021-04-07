//
//  Label.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class Label: UILabel {

    enum LabelStyle {
        case title
        case body
        case bodyBold
        case nickname
        case info
    }
    
    init(_ labelText: String? = nil, style: LabelStyle, fontSize: CGFloat? = nil, adaptToLightMode: Bool = true) {
        super.init(frame: .zero)
        
        text = labelText
        textColor = adaptToLightMode ? UIColor(named: "XYTint") : UIColor(named: "XYWhite")
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.0
        
        switch style {
        case .title:
            font = UIFont(name: "Raleway-Heavy", size: fontSize ?? 26)
        case .body:
            font = UIFont(name: "Raleway-Medium", size: fontSize ?? 10)
        case .bodyBold:
            font = UIFont(name: "Raleway-Bold", size: fontSize ?? 10)
        case .nickname:
            font = UIFont(name: "Raleway-Heavy", size: fontSize ?? 20)
        case .info:
            font = UIFont(name: "Raleway-Regular", size: fontSize ?? 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var enableShadow: Bool = false {
        didSet {
            layer.shadowOpacity = enableShadow ? 1.0 : 0.0
        }
    }
}
