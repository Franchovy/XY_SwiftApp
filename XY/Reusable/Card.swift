//
//  Card.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class Card: UIView {

    let backgroundLayer = CALayer()
    
    init(backgroundColor: UIColor = UIColor(named: "XYCard")!) {
        super.init(frame: .zero)
        
        backgroundLayer.backgroundColor = backgroundColor.cgColor
        backgroundLayer.masksToBounds = true
        backgroundLayer.cornerRadius = 15
        layer.insertSublayer(backgroundLayer, at: 0)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
    }
}
