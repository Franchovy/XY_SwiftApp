//
//  TextField.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class TextField: UITextField {

    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        
        if let placeholder = placeholder {
            self.placeholder = placeholder
        }
        
        font = UIFont(name: "Raleway-Medium", size: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    var inset: CGFloat = 10

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

}
