//
//  Label.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class Label: UILabel {

    enum LabelStyle {
        case title
        case body
        case bodyBold
        case nickname
        case info
    }
    
    private var textImage: UIImage?
    var gradient: CGGradient?
    
    init(_ labelText: String? = nil, style: LabelStyle, fontSize: CGFloat? = nil, adaptToLightMode: Bool = true) {
        super.init(frame: .zero)
        
        text = labelText
        textColor = adaptToLightMode ? UIColor(named: "XYTint") : UIColor(named: "XYWhite")
        
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.0
        
        switch style {
        case .title:
            font = UIFont(name: "Raleway-Heavy", size: fontSize ?? 26)
        case .body:
            font = UIFont(name: "Raleway-Medium", size: fontSize ?? 10)
        case .bodyBold:
            font = UIFont(name: "Raleway-Bold", size: fontSize ?? 10)
        case .nickname:
            font = UIFont(name: "Raleway-Heavy", size: fontSize ?? 20)
        case .info:
            font = UIFont(name: "Raleway-Regular", size: fontSize ?? 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var enableShadow: Bool = false {
        didSet {
            layer.shadowOpacity = enableShadow ? 0.7 : 0.0
        }
    }
    
    func applyGradient(gradientColours: [UIColor]) {
        gradient = CGGradient(
            colorsSpace: nil,
            colors: gradientColours.map({ $0.cgColor }) as CFArray,
            locations: nil
        )
    }
    
    public func setText(_ text: String, applyingBoldInRange range: NSRange? = nil) {
        if range != nil {
            let string = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font:font])
            string.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-Bold", size: font.pointSize), range: range!)
            // set label Attribute
            self.attributedText = string
        } else {
            self.text = text
        }
    }
    
    public func prepareForReuse() {
        textImage = nil
        gradient = nil
    }
    
    override open func draw(_ rect: CGRect) {
        if let gradient = gradient {
            let size = bounds.size
            
            let start = CGPoint(x: 0.3, y: 0.53)
            let end = CGPoint(x: 0.7, y: 0.47)
            
            if textImage == nil {
                let drawText = {
                    let backgroundColor = self.layer.backgroundColor

                    self.layer.backgroundColor = UIColor.clear.cgColor
                    super.draw(rect)
                    self.layer.backgroundColor = backgroundColor
                }

                if #available(iOS 10.0, *) {
                    textImage = UIGraphicsImageRenderer(size: size).image { _ in drawText() }
                } else {
                    UIGraphicsBeginImageContext(size)
                    defer { UIGraphicsEndImageContext() }

                    drawText()
                    textImage = UIGraphicsGetImageFromCurrentImageContext()
                }
            }

            if let context = UIGraphicsGetCurrentContext() {
                context.drawLinearGradient(gradient,
                                       start: CGPoint(x: start.x * size.width, y: start.y * size.height),
                                       end: CGPoint(x: end.x * size.width, y: end.y * size.height),
                                       options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
            }
            
            textImage?.draw(at: .zero, blendMode: .destinationIn, alpha: 1.0)

            
        } else {
            super.draw(rect)
        }
    }
}
