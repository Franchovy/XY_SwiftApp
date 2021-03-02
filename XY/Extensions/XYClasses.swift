//
//  XYClasses.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import UIKit

class XYLabel: UILabel {
    enum FontStyle {
        case bold
        case extraBold
        case medium
        
        var fontName: String {
            switch self {
            case .bold:
                return "Raleway-Bold"
            case .extraBold:
                return "Raleway-ExtraBold"
            case .medium:
                return "Raleway-Medium"
            }
        }
    }
    
    enum TintStyle {
        case auto
        case white
        case black
        
        var color: UIColor {
            switch self {
            case .auto:
                return UIColor(named: "tintColor")!
            case .white:
                return UIColor.white
            case .black:
                return UIColor.black
            }
        }
    }
    
    init(text: String = "", fontSize: CGFloat, fontStyle: FontStyle, tintStyle: TintStyle, shadowEnabled: Bool) {
        super.init(frame: .zero)
        
        font = UIFont(name: fontStyle.fontName, size: fontSize)
        
        textColor = tintStyle.color
        self.text = text
        
        if shadowEnabled {
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowRadius = 6
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.86
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

