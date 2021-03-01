//
//  GradientButton.swift
//  XY
//
//  Created by Maxime Franchot on 12/02/2021.
//

import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer:CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        return l
    }()
    
    private var colours = [UIColor]()
    
    init() {
        super.init(frame: .zero)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    public func setGradient(_ colors: [UIColor]) {
        self.colours = colors
        gradientLayer.colors = colours.map({ $0.cgColor })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        gradientLayer.colors = colours.map({
            $0.withAlphaComponent(0.5).cgColor
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        gradientLayer.colors = colours.map({ $0.cgColor })
    }
}
