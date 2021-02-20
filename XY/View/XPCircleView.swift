//
//  XPCircleView.swift
//  XY
//
//  Created by Maxime Franchot on 20/02/2021.
//

import UIKit

class XPCircleView: UIView {
    
    let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.darkGray.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1.4
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        return layer
    }()
    
    let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = 9.0
        
        return layer
    }()
    
    let glowShadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = 9.0
        layer.shadowColor = UIColor(red: 255, green: 0, blue: 0).cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 6.5
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        return layer
    }()
    
    let lifeCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        layer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 5, height: 5)).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        return layer
    }()
    
    let lifeProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = 2.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1.5
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        
        return layer
    }()
    
    private var lifeProgress:CGFloat = 0.8
    private var xpProgress:CGFloat = 0.4
    
    init() {
        super.init(frame: .zero)
        
        layer.addSublayer(glowShadowLayer)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(lifeProgressLayer)
        layer.addSublayer(lifeCircle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = width/2
        let innerRadius = radius * 0.95
        let lifeCircleRadius = radius * 0.85
        
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: innerRadius, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        progressLayer.path = innerCirclePath.cgPath
        progressLayer.strokeEnd = xpProgress
        glowShadowLayer.path = innerCirclePath.cgPath
        glowShadowLayer.strokeEnd = xpProgress
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: width/2, y: height/2), radius: radius, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        backgroundLayer.path = circlePath.cgPath
        
        lifeProgressLayer.path = circlePath.cgPath
        lifeProgressLayer.strokeEnd = lifeProgress * xpProgress
        
        let lifeProgressAngle: CGFloat = 2 * .pi * lifeProgress
        
        print("Angle: \(lifeProgressAngle)")
        let lifeCirclePoint = CGPoint(
            x: -sin(lifeProgressAngle) * lifeCircleRadius,
            y: cos(lifeProgressAngle) * lifeCircleRadius
        )
        print("Point: \(lifeCirclePoint)")
        lifeCircle.frame.origin = CGPoint(
            x: width/2 + lifeCirclePoint.x,
            y: height/2 + lifeCirclePoint.y
        )
    }
    
    func configure(xpModel: XPModel) {
        
    }
    
}
