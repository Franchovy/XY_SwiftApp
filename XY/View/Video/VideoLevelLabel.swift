//
//  VideoLevelLabel.swift
//  XY
//
//  Created by Maxime Franchot on 20/03/2021.
//

import UIKit

class VideoLevelLabel: UIView {

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
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = bounds
        gradientLayer.frame = bounds
    }
    
    enum Levels: Int {
        case new
        case rising
        case trend
        case hype
        case unicorn
        case goat
    }
    
    public func configure(for level: Levels) {
        gradientLayer.colors = []
        
        switch level {
        case .new:
            gradientLayer.backgroundColor = UIColor(0xCAF035).cgColor
            label.textColor = UIColor(0x262728)
            label.text = "New"
        case .rising:
            gradientLayer.backgroundColor = UIColor(0x3985FD).cgColor
            label.textColor = UIColor(0x262728)
            label.text = "Rising"
        case .trend:
            gradientLayer.backgroundColor = UIColor(0xFF8740).cgColor
            label.textColor = UIColor(0x262728)
            label.text = "Trend"
        case .hype:
            gradientLayer.backgroundColor = UIColor(0xFF3C4B).cgColor
            label.textColor = UIColor(0x262728)
            label.text = "Hype"
        case .unicorn:
            gradientLayer.backgroundColor = UIColor(0xECDFB2).cgColor
            gradientLayer.colors = [
                UIColor(0x74D0D5).cgColor,
                UIColor(0x91D4CD).cgColor,
                UIColor(0xECDFB2).cgColor,
                UIColor(0xF3CED0).cgColor,
                UIColor(0xF3B3D5).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.8)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.2)
            label.textColor = UIColor(0x262728)
            label.text = "Unicorn"
        case .goat:
            gradientLayer.backgroundColor = UIColor(named: "XYBlack-1")!.cgColor
            label.textColor = UIColor(0xF8D92D)
            label.text = "G.O.A.T."
        }
    }
    
    public func getColor() -> UIColor {
        return UIColor(cgColor: gradientLayer.backgroundColor!)
    }
}
