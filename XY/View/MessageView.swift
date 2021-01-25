//
//  MessageView.swift
//  XY
//
//  Created by Maxime Franchot on 25/01/2021.
//

import UIKit

enum CaptionColor {
    case blue
    case pink
    
    var gradient: [CGColor] {
        switch self {
        case .blue: return [
            UIColor(0x466AFF).cgColor,
            UIColor(0x629EFF).cgColor
        ]
        case .pink: return [
            UIColor(0xFF0062).cgColor,
            UIColor(0xFF5585).cgColor
        ]
        }
    }
}

class MessageView: UIView {

    private var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        return label
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    init() {
        super.init(frame: .zero)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.95)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.15)
        
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
        
        addSubview(label)
        
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        label.sizeToFit()
        label.frame = CGRect(
            x: 14,
            y: 14,
            width: label.width,
            height: label.height
        )
        
        gradientLayer.frame = bounds
    }
    
    func setText(_ text: String) {
        label.text = text
        
        label.sizeToFit()
        
        frame = CGRect(
            x: 0,
            y: 0,
            width: label.width + 28,
            height: label.height + 28
        )
        
        setNeedsLayout()
    }
    
    func setColor(_ color: CaptionColor) {
        gradientLayer.colors = color.gradient
    }
    
}
