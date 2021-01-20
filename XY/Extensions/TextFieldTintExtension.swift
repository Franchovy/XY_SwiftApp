//
//  TextFieldTintExtension.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/01/2021.
//

import UIKit


extension UITextField {
    @objc func modifyClearButton(with image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(UITextField.clear(_:)), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .whileEditing
    }

    @objc func clear(_ sender : AnyObject) {
    if delegate?.textFieldShouldClear?(self) == true {
        self.text = ""
        sendActions(for: .editingChanged)
    }
}
}
