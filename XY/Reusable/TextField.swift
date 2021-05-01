//
//  TextField.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class TextField: UITextView {
    
    let shadowLayer = CALayer()
    let maxCharsLabel: UILabel?
    let maxChars: Int?
    
    let placeholder: String?
    var placeholderActive:Bool
    
    var blockedCharacters: [Character]?

    init(placeholder: String? = nil, style: Style = .card, maxChars: Int? = nil, numLines: Int? = nil, font: UIFont? = nil) {
        if let maxChars = maxChars {
            self.maxChars = maxChars
            maxCharsLabel = Label("0/\(maxChars)", style: .bodyBold, fontSize: 10)
            maxCharsLabel?.textAlignment = .right
            maxCharsLabel!.alpha = 0.7
        } else {
            self.maxChars = nil
            maxCharsLabel = nil
        }
        
        placeholderActive = placeholder != nil
        self.placeholder = placeholder
        
        super.init(frame: .zero, textContainer: nil)
        
        if let maxCharsLabel = maxCharsLabel {
            addSubview(maxCharsLabel)
        }
        
        setStyle(style)
        self.font = font
        
        text = placeholder
        if placeholderActive {
            textColor = textColor?.withAlphaComponent(0.5)
        }
        
        isScrollEnabled = false
        textContainerInset = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        )
        if let numLines = numLines {
            textContainer.maximumNumberOfLines = numLines
        }
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
        shadowLayer.shadowRadius = 1
        shadowLayer.shadowOpacity = 0.6
        
        layer.insertSublayer(shadowLayer, at: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditing), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndEditing), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        shadowLayer.frame = bounds
        
        maxCharsLabel?.sizeToFit()
        maxCharsLabel?.frame = CGRect(
            x: width - maxCharsLabel!.width - 10 - 25,
            y: height - maxCharsLabel!.height - 5,
            width: maxCharsLabel!.width + 25,
            height: maxCharsLabel!.height
        )
    }
    
    enum Style {
        case clear
        case card
    }
    
    public func disallowCharacters(_ characters: [Character]) {
        blockedCharacters = characters
    }
    
    public func setText(_ text: String) {
        self.text = text
        placeholderActive = false
        textColor = textColor?.withAlphaComponent(1.0)
        
        if let maxChars = maxChars {
            maxCharsLabel!.text = "\(text.count)/\(maxChars)"
        }
    }
    
    public func setStyle(_ style: Style) {
        switch style {
        case .clear:
            shadowLayer.isHidden = true
        case .card:
            layer.cornerRadius = 15
            layer.sublayers?.filter({$0 != shadowLayer}).forEach({$0.masksToBounds = true})
            backgroundColor = UIColor(named: "XYCard")
            textColor = UIColor(named: "XYTint")
        }
    }

    @objc private func textDidChange(notification: Notification) {
        guard let obj = notification.object as? NSObject, obj == self else {
            return
        }
        
        if let maxChars = maxChars {
            if text.count > maxChars ||
                (blockedCharacters != nil && text.last != nil && blockedCharacters!.contains(text.last!))
            {
                text.popLast()
                reverseBounceAnimation()
                return
            }
            
            maxCharsLabel!.text = "\(text.count)/\(maxChars)"
        }
    }
    
    @objc private func didBeginEditing(notification: Notification) {
        guard let obj = notification.object as? NSObject, obj == self else {
            return
        }
        
        if placeholderActive {
            text = ""
            placeholderActive = false
            textColor = textColor?.withAlphaComponent(1.0)
        }
        
        bounceAnimation()
    }
    
    @objc private func didEndEditing(notification: Notification) {
        guard let obj = notification.object as? NSObject, obj == self else {
            return
        }
        
        if text == "" {
            text = placeholder
            placeholderActive = true
            textColor = textColor?.withAlphaComponent(0.5)
        }
        
        reverseBounceAnimation()
    }
}
 
