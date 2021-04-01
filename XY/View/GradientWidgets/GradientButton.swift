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
    
    private var shadowLayer: CAShapeLayer!

    private var colours = [UIColor]()
    
    enum Style {
        case basic
        case `default`
    }
    
    init(text: String? = nil, textColor: UIColor? = nil, gradient: [UIColor]? = nil, style: Style = .default) {
        super.init(frame: .zero)
        
        if let text = text {
            setTitle(text, for: .normal)
        }
        if let textColor = textColor {
            setTitleColor(textColor, for: .normal)
        }
        if let gradient = gradient {
            setGradient(gradient)
        }
        
        switch style {
        case .basic:
            titleLabel?.font = UIFont(name: "Raleway-Bold", size: 14)
        case .default:
            break
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        clipsToBounds = false
        layer.masksToBounds = false
        gradientLayer.masksToBounds = true
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: height/2).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0, height: 3.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 6

            layer.insertSublayer(shadowLayer, at: 0)
        }
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
