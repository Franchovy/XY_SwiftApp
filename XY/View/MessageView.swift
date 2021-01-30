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
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 10)
        label.textColor = .white
        
        return label
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
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
            return label.text ?? ""
        }
        set {
            label.text = newValue
            
            frame.size = getSize()
            
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
    
    public func getSize() -> CGSize {
        
        let labelWidth = min(label.width, 275)
        
        label.frame.size.width = labelWidth
        label.sizeToFit()
        
        let minWidth = nameLabel.width + dateLabel.width + 15
        
        let numRows:CGFloat = CGFloat(label.calculateMaxLines())
        return CGSize(
            width: max(minWidth, labelWidth + 28),
            height: numRows * label.font.lineHeight + 28
        )
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
        
//        translatesAutoresizingMaskIntoConstraints = false
//        label.translatesAutoresizingMaskIntoConstraints = false
        
//        addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 19.0))
//        addConstraint(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 6.0))
//        addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16.0))
//        addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 13.0))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()

        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(
            x: 5.94,
            y: 3.72,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        label.frame = CGRect(
            x: 14,
            y: nameLabel.bottom + 3,
            width: label.width,
            height: label.height
        )
        
        textField.sizeToFit()
        textField.frame = CGRect(
            x: 14,
            y: 16,
            width: textField.width,
            height: textField.height
        )
        
        dateLabel.sizeToFit()
        dateLabel.frame = CGRect(
            x: width - dateLabel.width - 5,
            y: 4,
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
            
            if label.text == "Write your caption here" {
                textField.text = ""
                text = ""
                frame.size.width = 25
            }
        } else {
            label.text = textField.text == "" ? label.text : textField.text
            textField.isHidden = true
            label.isHidden = false
            textField.resignFirstResponder()
        }
    }
    
    @objc private func onTextFieldChange() {
        guard let text = textField.text else {
            return
        }
        
        if text.count >= 50 {
            textField.text = String(text.prefix(50))
        } else {
            textField.text = text
        }

        textField.sizeToFit()
        
        label.text = text
        label.frame.size.width = min(textField.width, 350)
        label.sizeToFit()
        
        frame.size = CGSize(
            width: label.width + 28,
            height: label.font.lineHeight + 28
        )
        
    }
}
