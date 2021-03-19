//
//  TextViewCard.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class TextViewCard: UITextView, UITextViewDelegate {

    private let charsLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 10)
        label.textColor = UIColor(named: "XYTint")
        label.isHidden = true
        return label
    }()
    
    private var maxChars: Int?
    private var placeholder: String?
    
    private let cardLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(named: "XYCard")?.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        return layer
    }()
    
    var isPlaceholderShowing = false
    
    var onFinishedEditing: ((String) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
        
        layer.insertSublayer(cardLayer, at: 0)
        
        backgroundColor = .clear
        textColor = UIColor(named: "XYTint")
        font = UIFont(name: "Raleway-Medium", size: 10)
        
        addSubview(charsLabel)
        
        didChangeText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardLayer.frame = bounds
        
        layoutCharsLabel()
    }
    
    private func layoutCharsLabel() {
        charsLabel.sizeToFit()
        charsLabel.frame = CGRect(
            x: width - charsLabel.width - 8,
            y: height - charsLabel.height - 4,
            width: charsLabel.width,
            height: charsLabel.height
        )
    }
    
    public func setMaxChars(maxChars: Int) {
        self.maxChars = maxChars
        self.charsLabel.isHidden = false
    }
    
    public func setPlaceholderText(text: String) {
        placeholder = text
        
        setPlaceholderActive(true)
    }
    
    public func setText(_ text: String) {
        setPlaceholderActive(false)
        
        self.text = text
        didChangeText()
    }
    
    private func setPlaceholderActive(_ active: Bool) {
        if active {
            if self.text == "" {
                self.text = placeholder
            }
            
            textColor = textColor?.withAlphaComponent(0.3)
            isPlaceholderShowing = true
        } else {
            text = ""
            
            textColor = textColor?.withAlphaComponent(0.6)
            isPlaceholderShowing = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isPlaceholderShowing {
            setPlaceholderActive(false)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        didChangeText()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text == "" {
            setPlaceholderActive(true)
        } else {
            onFinishedEditing?(text!)
        }
    }
    
    private func didChangeText() {
        
        if let maxChars = maxChars, text != nil {
            charsLabel.text = "\(min(text!.count, maxChars))/\(maxChars)"
            layoutCharsLabel()
            
            if text!.count > maxChars {
                text = String(text!.prefix(maxChars))
                return
            }
        }
    }
}
