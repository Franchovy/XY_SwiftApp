//
//  TextFieldCard.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class TextFieldCard: UITextField, UITextFieldDelegate {
    
    private var maxChars: Int?
    
    private let cardLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        return layer
    }()
    
    var textPadding = UIEdgeInsets(
        top: 10,
        left: 20,
        bottom: 10,
        right: 20
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override var backgroundColor: UIColor? {
        set {
            cardLayer.backgroundColor = newValue?.cgColor
        }
        get {
            return cardLayer.backgroundColor == nil ? nil : UIColor(cgColor: cardLayer.backgroundColor!)
        }
    }
    
    var isPlaceholderShowing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        
        layer.insertSublayer(cardLayer, at: 0)
        
        backgroundColor = .clear
        
        didChangeText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardLayer.frame = bounds
    }
    
    public func setMaxChars(maxChars: Int) {
        self.maxChars = maxChars
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let centerPoint = center
        sizeToFit()
        UIView.animate(withDuration: 0.1) {
            self.center = centerPoint
        }
        
        didChangeText()
    }
    
    private func didChangeText() {
        
        if let maxChars = maxChars, text != nil {
            
            if text!.count > maxChars {
                text = String(text!.prefix(maxChars))
                return
            }
        }
    }
}
