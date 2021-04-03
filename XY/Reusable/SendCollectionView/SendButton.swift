//
//  SendButton.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class SendButton: UIButton {

    private let gradientLayer = CAGradientLayer()
    var isPressed = false
    
    init() {
        super.init(frame: .zero)
        
        setTitle("Send", for: .normal)
        
        gradientLayer.colors = Global.xyGradient.map({ $0.cgColor })
        gradientLayer.startPoint = CGPoint(x: 0.1, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        
        gradientLayer.masksToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel?.font = UIFont(name: "Raleway-Bold", size: 14)
        setTitleColor(UIColor(named: "XYWhite"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = height/2
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size = CGSize(width: 65, height: 23)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        gradientLayer.opacity = 0.5
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        isPressed = !isPressed
        
        if isPressed {
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            gradientLayer.backgroundColor = UIColor(named: "XYBackground")?.cgColor
            gradientLayer.borderColor = UIColor(named: "XYTint")?.cgColor
            gradientLayer.borderWidth = 2
            
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
            setTitle("Ready", for: .normal)
        } else {
            gradientLayer.colors = Global.xyGradient.map({$0.cgColor})
            gradientLayer.opacity = 1.0
            gradientLayer.borderWidth = 0
            
            setTitleColor(UIColor(named: "XYWhite"), for: .normal)
            setTitle("Sent", for: .normal)
        }
    }
}
