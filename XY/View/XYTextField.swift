//
//  XYTextField.swift
//  XY
//
//  Created by Maxime Franchot on 28/03/2021.
//

import UIKit

class XYTextField: UITextField {

    let insets = UIEdgeInsets(
        top: 16,
        left: 16,
        bottom: 16,
        right: 16
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
         return super.textRect(forBounds: bounds)
    }
 
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
         return super.editingRect(forBounds: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let button = rightView as? UIButton {
            button.imageEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -16,
                bottom: 0,
                right: 16
            )

            button.frame.origin.x -= 14
        }
    }
    
    enum Side {
        case left
        case right
    }
    
    func setRightButton(side: Side, image: UIImage?, target: Any?, selector: Selector) {
        if (side == .right && rightView == nil) || (side == .left && leftView == nil) {
            let button = UIButton()
            button.contentMode = .scaleToFill
            button.setBackgroundImage(image, for: .normal)
            button.addTarget(target, action: selector, for: .touchUpInside)
            button.tintColor = tintColor
            
            if side == .right {
                rightView = button
            } else {
                leftView = button
            }
        }
    }
}
