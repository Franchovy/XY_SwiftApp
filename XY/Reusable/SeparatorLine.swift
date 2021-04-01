//
//  SeparatorLine.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class SeparatorLine: UIView {

    init() {
        super.init(frame: .zero)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "XYCard")!.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPosition(y: CGFloat, width: CGFloat) {
        frame = CGRect(
            x: 0,
            y: y,
            width: width,
            height: 1
        )
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.borderColor = UIColor(named: "XYCard")!.cgColor
    }
}
