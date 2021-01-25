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

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.textColor = .white
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
        label.textColor = .white
        
        return label
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = .white
        return label
    }()
    
    private var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont(name: "HelveticaNeue", size: 15)
        textField.isHidden = true
        return textField
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    public var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
            nameLabel.sizeToFit()
        }
    }
    
    public var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            label.text = newValue
            
            label.sizeToFit()
            
            frame = CGRect(
                x: 0,
                y: 0,
                width: label.width + 28,
                height: label.height + 28
            )
            
            setNeedsLayout()
        }
    }
    
    public var timestamp: String {
        get {
            return dateLabel.text ?? ""
        }
        set {
            dateLabel.text = newValue
            dateLabel.sizeToFit()
        }
    }
    
    public var isEditable: Bool = false
    
    init() {
        super.init(frame: .zero)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.95)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.15)
        
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
        
        addSubview(label)
        addSubview(textField)
        addSubview(nameLabel)
        addSubview(dateLabel)
        
        layer.cornerRadius = 10
        
        textField.addTarget(self, action: #selector(onTextFieldChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.sizeThatFits(CGSize(width: width - 28, height: height - 28))
        
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
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 4,
            y: 2,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        dateLabel.sizeToFit()
        dateLabel.frame = CGRect(
            x: width - dateLabel.width - 5,
            y: height - dateLabel.height - 2,
            width: dateLabel.width,
            height: dateLabel.height
        )
        
        gradientLayer.frame = bounds
    }
    
    func setColor(_ color: CaptionColor) {
        gradientLayer.colors = color.gradient
    }
    
    func toggleInputMode(inputMode: Bool) {
        guard isEditable == true else { return }
        
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
        
        setNeedsLayout()
    }
}
