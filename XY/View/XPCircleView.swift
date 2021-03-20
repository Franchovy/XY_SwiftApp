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
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineWidth = 9.0
        layer.shadowColor = UIColor(red: 255, green: 0, blue: 0).cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2.5
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        return layer
    }()
    
    let label:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 15)
        label.textColor = UIColor(named: "XYTint")
        return label
    }()
    
    private var xpProgress:CGFloat = 0.0
    
    init() {
        super.init(frame: .zero)
        
        layer.addSublayer(glowShadowLayer)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
        addSubview(label)
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
        
        layoutLabel()
    }
    
    private func layoutLabel() {
        label.sizeToFit()
        label.frame = CGRect(
            x: (width - label.width)/2,
            y: (height - label.height)/2 * 0.6,
            width: label.width,
            height: label.height
        )
    }
    
    enum Thickness {
        case thin
        case medium
        case thick
    }
    
    public func setColor(_ color: UIColor, labelColor: UIColor? = nil) {
        glowShadowLayer.shadowColor = color.cgColor
        glowShadowLayer.strokeColor = color.cgColor
        progressLayer.strokeColor = color.cgColor
        
        if labelColor != nil {
            label.textColor = labelColor
        }
    }
    
    public func setThickness(_ thickness: Thickness) {
        switch thickness {
        case .thin:
            backgroundLayer.lineWidth = 2.5
            progressLayer.lineWidth = 4.0
            glowShadowLayer.lineWidth = 4.0
        case .medium:
            backgroundLayer.lineWidth = 3.0
            progressLayer.lineWidth = 5.0
            glowShadowLayer.lineWidth = 5.0
        case .thick:
            backgroundLayer.lineWidth = 2.0
            progressLayer.lineWidth = 4.0
            glowShadowLayer.lineWidth = 5.0
        }
    }
    
    func configure(xpModel: XPModel) {
        
    }
    
    public func setLabel(_ text: String) {
        label.text = text
        
        layoutLabel()
    }
    
    public func setProgress(_ progress: CGFloat) {
        xpProgress = progress
    }
    
    public func animateSetProgress(_ progress: CGFloat) {
        self.xpProgress = progress
        
        UIView.animate(withDuration: 0.5) {
            self.updateCircleViewProgress()
        }
        
    }
    
    private func updateCircleViewProgress() {
        progressLayer.strokeEnd = xpProgress
        glowShadowLayer.strokeEnd = xpProgress
    }
}
