//
//  GradientBorderButtonWithShadow.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit

class GradientBorderButtonWithShadow: UIButton {

    private let loginButtonGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.locations = [0.0, 1.0]
        return layer
    }()

    private let loginShape: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.borderColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    
    private var bgColor: UIColor?
    private var gradientColors = [UIColor]()
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(loginButtonGradient)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loginButtonGradient.frame = bounds
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: height/2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        loginButtonGradient.mask = shape
        
    }
    
    public func setGradient(_ colours: [UIColor]) {
        loginButtonGradient.colors = colours.map({ $0.cgColor })
        
        gradientColors = colours
    }
    
    func setBackgroundColor(color: UIColor) {
        bgColor = color
        backgroundColor = bgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        backgroundColor = bgColor?.withAlphaComponent(0.7)
        loginButtonGradient.colors = gradientColors.map({ $0.withAlphaComponent(0.5).cgColor })
        tintColor = tintColor.withAlphaComponent(0.5)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        backgroundColor = bgColor
        loginButtonGradient.colors = gradientColors.map({ $0.cgColor })
        tintColor = tintColor.withAlphaComponent(1.0)
    }
    
}
