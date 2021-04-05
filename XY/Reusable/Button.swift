//
//  Button.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class Button: UIButton {
    
    enum Style : Equatable {
        case circular(backgroundColor: UIColor)
        case card
        case roundButton(backgroundColor: UIColor)
        case roundButtonBorder(gradient: [UIColor])
        case text
    }
    let style: Style
    
    enum TitlePosition {
        case belowImage
    }
    let titlePosition: TitlePosition?
    let padding: UIEdgeInsets
    
    var gradientLayer = CAGradientLayer()
    var shapeLayer = CAShapeLayer()
    var backgroundLayer = CALayer()
    
    init(
        image: UIImage? = nil,
        title: String? = nil,
        style: Style,
        titlePosition: TitlePosition? = nil,
        font: UIFont? = nil,
        paddingVertical: CGFloat = 15,
        paddingHorizontal: CGFloat = 15,
        imageSizeIncrease: CGFloat = 0
    ) {
        self.style = style
        self.titlePosition = titlePosition
        self.padding = UIEdgeInsets(top: paddingVertical, left: paddingHorizontal, bottom: paddingVertical, right: paddingHorizontal)
        
        super.init(frame: .zero)
        
        imageView?.contentMode = .scaleAspectFill

        setImage(image, for: .normal)
        tintColor = UIColor(named: "XYWhite")
        
        setTitle(title, for: .normal)
        titleLabel?.font = font
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.7
        
        switch style {
        case .circular(let backgroundColor):
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        case .card:
            backgroundLayer.backgroundColor = UIColor(named: "XYCard")!.cgColor
        case .roundButton(let backgroundColor):
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        case .roundButtonBorder(let gradientColors):
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors.map({ $0.cgColor })
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.2)
            gradientLayer.mask = shapeLayer
            
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.borderWidth = 2
            shapeLayer.borderColor = UIColor.black.cgColor
            
            layer.insertSublayer(gradientLayer, at: 0)
        case .text:
            layer.shadowOpacity = 0.0
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
        }
        
        backgroundLayer.masksToBounds = true
    
        layer.insertSublayer(backgroundLayer, below: imageView?.layer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch style {
        case .card:
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = 15
        case .circular(backgroundColor: _):
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = height/2
        case .roundButton(backgroundColor: _):
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = height/2
        case .roundButtonBorder(gradient: _):
            shapeLayer.frame = bounds
            shapeLayer.cornerRadius = height/2
            shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: height/2).cgPath
            gradientLayer.frame = bounds
        case .text:
            backgroundLayer.frame = bounds
        }
        
        switch titlePosition {
        case .belowImage:
            guard
                let imageViewSize = self.imageView?.frame.size,
                let titleLabelSize = self.titleLabel?.frame.size else {
                break
            }
            
            let totalHeight = imageViewSize.height + titleLabelSize.height + padding.top
            
            self.imageEdgeInsets = UIEdgeInsets(
                top: -(totalHeight - imageViewSize.height),
                left: 0.0,
                bottom: 0.0,
                right: -titleLabelSize.width
            )
            
            self.titleEdgeInsets = UIEdgeInsets(
                top: 0.0,
                left: -imageViewSize.width,
                bottom: -(totalHeight - titleLabelSize.height),
                right: 0.0
            )
            
            self.contentEdgeInsets = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: titleLabelSize.height,
                right: 0.0
            )
        default:
            break
        }
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        if style != .text {
            frame.size.width = intrinsicContentSize.width + padding.left + padding.right
            frame.size.height = intrinsicContentSize.height + padding.top + padding.bottom
        }
    }
    
    var isAnimateSelected = false
    
    private func animateSelect() {
        guard !isAnimateSelected else {
            return
        }
        
        alpha = 0.8
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        isAnimateSelected = true
    }
    
    private func animateDeselect() {
        guard isAnimateSelected else {
            return
        }
        
        alpha = 1.0
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
        isAnimateSelected = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
                
        animateSelect()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        animateDeselect()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        animateDeselect()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if isHighlighted {
            animateSelect()
        } else {
            animateDeselect()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.4
        }
    }
}
