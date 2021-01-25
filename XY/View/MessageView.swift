//
//  MessageView.swift
//  XY
//
//  Created by Maxime Franchot on 25/01/2021.
//

import UIKit

enum CaptionColor {
    case blue
    case pink
    
    var gradient: [CGColor] {
        switch self {
        case .blue: return [
            UIColor(0x466AFF).cgColor,
            UIColor(0x629EFF).cgColor
        ]
        case .pink: return [
            UIColor(0xFF0062).cgColor,
            UIColor(0xFF5585).cgColor
        ]
        }
    }
}

class MessageView: UIView, UITextFieldDelegate {

    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        return label
    }()
    
    private var textField: UITextField = {
        let textField = UITextField()
        
        textField.font = UIFont(name: "HelveticaNeue", size: 20)
        return textField
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    public var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
            textField.sizeToFit()
            
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.95)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.15)
        
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
        
        addSubview(label)
        addSubview(textField)
        textField.isHidden = true
        
        layer.cornerRadius = 10
        
        textField.addTarget(self, action: #selector(onTextFieldChange), for: .editingChanged)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        label.sizeToFit()
        label.frame = CGRect(
            x: 14,
            y: 14,
            width: width - 28,
            height: height - 28
        )
        
        textField.sizeToFit()
        textField.frame = CGRect(
            x: 14,
            y: 14,
            width: width - 28,
            height: height - 28
        )
        
        gradientLayer.frame = bounds
    }
    
    func setText(_ text: String) {
        label.text = text
        
        label.sizeToFit()
        
        frame = CGRect(
            x: 0,
            y: 0,
            width: label.width + 28,
            height: label.height + 28
        )
        
        setNeedsLayout()
    }
    
    func setColor(_ color: CaptionColor) {
        gradientLayer.colors = color.gradient
    }
    
    func toggleInputMode(inputMode: Bool) {
        if inputMode {
            textField.isHidden = false
            label.isHidden = true
            textField.becomeFirstResponder()
            
        } else {
            label.text = textField.text == "" ? label.text : textField.text
            textField.isHidden = true
            label.isHidden = false
            textField.resignFirstResponder()
        }
    }
    
    @objc private func onTextFieldChange() {
        if let text = textField.text, text.count >= 30 {
            textField.text = String(text.prefix(30))
            return
        }
        
        textField.sizeToFit()
        
        frame = CGRect(
            x: 0,
            y: 0,
            width: textField.width + 28,
            height: textField.height + 28
        )
        
        
    }
}
