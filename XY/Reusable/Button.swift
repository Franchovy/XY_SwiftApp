//
//  Button.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class Button: UIButton {
    let contentView = UIView()
    
    enum Style : Equatable {
        case circular(backgroundColor: UIColor)
        case card
        case roundButton(backgroundColor: UIColor)
        case roundButtonGradient(gradient: [UIColor])
        case roundButtonBorder(gradient: [UIColor])
        case colorButton(color: UIColor, cornerRadius: CGFloat)
        case text
        case image
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
    
    var isAnimating = false
        
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
        
        addSubview(contentView)
        
        imageView?.contentMode = .scaleAspectFill

        setImage(image, for: .normal)
        tintColor = UIColor(named: "XYWhite")
        
        setTitle(title, for: .normal)
        titleLabel?.font = font
        
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowRadius = 1
        contentView.layer.shadowOpacity = 0.6
        
        contentView.layer.insertSublayer(backgroundLayer, below: imageView?.layer)
        
        switch style {
        case .circular(let backgroundColor):
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        case .card:
            backgroundLayer.backgroundColor = UIColor(named: "XYCard")!.cgColor
        case .roundButton(let backgroundColor):
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        case .roundButtonGradient(let gradientColors):
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors.map({ $0.cgColor })
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.2)
            
            contentView.layer.insertSublayer(gradientLayer, above: backgroundLayer)
            
            setTitleColor(.XYWhite, for: .normal)
        case .roundButtonBorder(let gradientColors):
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = gradientColors.map({ $0.cgColor })
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.2)
            gradientLayer.mask = shapeLayer
            
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.borderWidth = 2
            shapeLayer.borderColor = UIColor.black.cgColor
            
            contentView.layer.insertSublayer(gradientLayer, above: backgroundLayer)
            
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
            backgroundLayer.backgroundColor = UIColor(named: "XYBackground")?.cgColor
        case .text:
            contentView.layer.shadowOpacity = 0.0
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
        case .colorButton(let color, _):
            
            backgroundLayer.backgroundColor = color.cgColor
        case .image:
            contentMode = .scaleAspectFill
        }
        
        backgroundLayer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard !isAnimating else {
            return
        }
        
        super.layoutSubviews()
        
        contentView.frame = self.bounds
        
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
        case .roundButtonGradient(gradient: _):
            gradientLayer.frame = bounds
            gradientLayer.cornerRadius = height/2
        case .roundButtonBorder(gradient: _):
            shapeLayer.frame = bounds
            shapeLayer.cornerRadius = height/2
            backgroundLayer.cornerRadius = height/2
            shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: height/2).cgPath
            gradientLayer.frame = bounds
            backgroundLayer.frame = bounds
        case .text:
            backgroundLayer.frame = bounds
        case .colorButton(_, let cornerRadius):
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = cornerRadius
        case .image:
            break
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
    
    public func increaseTouchSize(by amount: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        if style != .text {
            frame.size.width = intrinsicContentSize.width + padding.left + padding.right
            frame.size.height = intrinsicContentSize.height + padding.top + padding.bottom
        }
    }
    
    private func animateSelect() {
        alpha = 0.8
        isAnimating = true
        
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.titleLabel?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.imageView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { (done) in
            if done {
                self.isAnimating = false
            }
        }
    }
    
    private func animateDeselect() {
        alpha = 1.0
        isAnimating = true
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.transform = .identity
            self.titleLabel?.transform = .identity
            self.imageView?.transform = .identity
        } completion: { (done) in
            if done {
                self.isAnimating = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
                
        HapticsManager.shared.vibrateImpact(for: .light)
        
        animateSelect()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if isSelected {
            HapticsManager.shared.vibrateImpact(for: .rigid)
        }
        
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
