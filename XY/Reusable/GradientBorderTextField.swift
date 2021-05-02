//
//  GradientBorderTextField.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit

class GradientBorderTextField: UITextField, UITextFieldDelegate {

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.locations = [0.0, 1.0]
        return layer
    }()

    private let borderShape: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.borderColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    
    private var shadowLayer: CAShapeLayer!
    
    private var bgColor: UIColor?
    private var gradientColors = [UIColor]()
    
    private var isManualSecureTextEntry = false
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: height/2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = shape
        
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: height/2).cgPath
            shadowLayer.fillColor = UIColor(named: "Black")!.cgColor

            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0, height: 3.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 6

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
    
    public func setGradient(_ colours: [UIColor]) {
        gradientLayer.colors = colours.map({ $0.cgColor })
        
        gradientColors = colours
    }
    
    func setBackgroundColor(color: UIColor) {
//        bgColor = color
//        backgroundColor = bgColor
    }
    
    public func setManualSecureEntry() {
        isManualSecureTextEntry = true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isManualSecureTextEntry {
            isSecureTextEntry = true
        }
    }
}
