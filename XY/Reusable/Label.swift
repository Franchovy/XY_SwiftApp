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
    }
    
    init(_ labelText: String? = nil, style: LabelStyle) {
        super.init(frame: .zero)
        
        text = labelText
        textColor = UIColor(named: "XYTint")
        
        switch style {
        case .title:
            font = UIFont(name: "Raleway-Heavy", size: 26)
        case .body:
            font = UIFont(name: "Raleway-Medium", size: 10)
        case .bodyBold:
            font = UIFont(name: "Raleway-Bold", size: 10)
        case .nickname:
            font = UIFont(name: "Raleway-Heavy", size: 20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
