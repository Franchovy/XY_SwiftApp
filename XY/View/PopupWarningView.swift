//
//  PopupWarningView.swift
//  XY
//
//  Created by Maxime Franchot on 18/03/2021.
//

import UIKit

class PopupWarningView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 20)
        label.textColor = UIColor(0xEF3A30)
        label.textAlignment = .center
        return label
    }()
    
    private let warningButton:UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: UIColor(0xEF3A30), forState: .normal)
        button.setTitleColor(UIColor(named: "XYWhite"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 20)
        return button
    }()
    
    private let confirmButtonSize = CGSize(width: 135, height: 50)
    private let backgroundLayer = CALayer()
    
    private let completion: (() -> Void)
        
    init(title: String, buttonText: String, completion: @escaping(() -> Void)) {
        self.completion = completion
        
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        warningButton.setTitle(buttonText, for: .normal)
        warningButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
                
        backgroundLayer.backgroundColor = UIColor.black.cgColor
        backgroundLayer.cornerRadius = 15
        backgroundLayer.masksToBounds = true
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.9
        layer.masksToBounds = false
        layer.addSublayer(backgroundLayer)
        
        addSubview(titleLabel)
        addSubview(warningButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (width - titleLabel.width)/2,
            y: 22.75,
            width: titleLabel.width,
            height: titleLabel.height
        )
                
        warningButton.frame = CGRect(
            x: (width - confirmButtonSize.width)/2,
            y: titleLabel.bottom + 34,
            width: confirmButtonSize.width,
            height: confirmButtonSize.height
        )
        warningButton.layer.cornerRadius = confirmButtonSize.height / 2
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size.width = superview?.width ?? 375 - 96
        
        titleLabel.sizeToFit()
        warningButton.frame.size = confirmButtonSize
        
        frame.size.height =
            titleLabel.height + 22.75 +
            warningButton.height + 34
            + 31
        
        backgroundLayer.frame.size = frame.size
    }
    
    @objc private func didTapConfirm() {
        completion()
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0.0
        } completion: { (done) in
            if done {
                self.removeFromSuperview()
            }
        }
    }
}
