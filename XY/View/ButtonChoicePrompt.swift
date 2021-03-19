//
//  ButtonChoicePrompt.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class ButtonChoicePrompt: UIView {

    private let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 26)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let cardLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(named: "XYCard")?.cgColor
        layer.cornerRadius = 15
        layer.masksToBounds = true
        return layer
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: "XYTint")
        return button
    }()
    
    private var onPress = [(() -> Void)]()
    private var buttons = [UIButton]()
    
    init() {
        super.init(frame: .zero)
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.4
        layer.shadowColor = UIColor.black.cgColor
        layer.insertSublayer(cardLayer, at: 0)
        
        addSubview(title)
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardLayer.frame = bounds.inset(by: UIEdgeInsets.init(top: 0, left: 0, bottom: 34.73, right: 0))
        
        title.sizeToFit()
        title.frame = CGRect(
            x: (width - title.width)/2,
            y: 5,
            width: title.width,
            height: title.height
        )
        
        let closeButtonSize:CGFloat = 17
        closeButton.frame = CGRect(
            x: (width - closeButtonSize)/2,
            y: height - closeButtonSize,
            width: closeButtonSize,
            height: closeButtonSize
        )
        
        let buttonSize = CGSize(width: width - 54, height: 44)
        var y = title.bottom + 20
        for button in buttons {
            button.frame = CGRect(
                x: 27,
                y: y,
                width: buttonSize.width,
                height: buttonSize.height
            )
            button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: buttonSize.width/2 - (button.titleLabel?.width ?? 0)/2)
            
            y = button.bottom + 20
        }
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size.width = (superview?.width ?? 375) - 50
        frame.size.height = 5 + title.height + CGFloat(buttons.count) * 64 + 18 + 17.73 + 17
        
    }
    
    public func addButton(buttonText: String, buttonIcon: UIImage?, onTap: @escaping(() -> Void)) {
        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Medium", size: 15)
        button.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        button.setBackgroundColor(color: UIColor(named: "Black")!, forState: .normal)
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        
        button.tintColor = UIColor(named: "XYTint")
        
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        
        addSubview(button)
        buttons.append(button)
        onPress.append {
            onTap()
        }
    }
    
    public func close() {
        closeButtonPressed()
    }
    
    @objc private func didPressButton(_ button: UIButton) {
        if let index = buttons.firstIndex(of: button) {
            onPress[index]()
        }
    }
    
    @objc private func closeButtonPressed() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        } completion: { (done) in
            if done {
                self.removeFromSuperview()
            }
        }
    }
}
