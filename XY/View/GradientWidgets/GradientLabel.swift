//
//  GradientLabel.swift
//  XY
//
//  Created by Maxime Franchot on 02/03/2021.
//

import UIKit

class GradientLabel: UIView {

    let gradientLayer = CAGradientLayer()
    let label = UILabel()
    
    init(text: String, fontSize: CGFloat, gradientColours: [UIColor]) {
        super.init(frame: .zero)
        
        // gradient colors in order which they will visually appear
        gradientLayer.colors = gradientColours.map({ $0.cgColor })

        // Gradient from left to right
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        // set the gradient layer to the same size as the view
        gradientLayer.frame = bounds
        // add the gradient layer to the views layer for rendering
        layer.addSublayer(gradientLayer)
        
        label.adjustsFontSizeToFitWidth = true
        label.text = text
        label.font = UIFont(name: "Raleway-Heavy", size: fontSize)
        label.textAlignment = .center
        label.textColor = .black
        addSubview(label)

        mask = label
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.frame = bounds
    }
    
}