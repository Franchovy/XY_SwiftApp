//
//  ColorLabel.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class ColorLabel: UIView {

    let gradientLayer = CAGradientLayer()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 10)
        label.textColor = UIColor(0x262728)
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        layer.addSublayer(gradientLayer)
        gradientLayer.cornerRadius = 5
        addSubview(label)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.7
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = bounds
        gradientLayer.frame = bounds
    }
    
    // MARK: - Public functions
    
    public func setBackgroundColor(_ color: UIColor) {
        gradientLayer.colors = []
        gradientLayer.backgroundColor = color.cgColor
    }
    
    public func setBackgroundColorGradient(_ colors: [UIColor]) {
        gradientLayer.colors = [
            UIColor(0x74D0D5).cgColor,
            UIColor(0x91D4CD).cgColor,
            UIColor(0xECDFB2).cgColor,
            UIColor(0xF3CED0).cgColor,
            UIColor(0xF3B3D5).cgColor
        ]
    }
    
    public func setTextColor(_ color: UIColor) {
        label.textColor = color
    }
    
    public func setText(_ text: String) {
        label.text = text
    }
    
    public func getColor() -> UIColor {
        return UIColor(cgColor: gradientLayer.backgroundColor!)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        label.sizeToFit()
        frame.size.width = label.width + 15
        frame.size.height = label.height + 6
        
        layoutSubviews()
    }
}
