//
//  Prompt.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class Prompt: UIView, UITextViewDelegate {
    
    // MARK: - ENUMS
    
    enum ButtonStyle {
        case embedded
        case action(style: Button.Style)
    }
    
    enum BackgroundStyle {
        case blur
        case fade
    }
    var backgroundStyle: BackgroundStyle = .blur
    
    // MARK: - UI PROPERTIES

    var blurEffectView: UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurView)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    var card = Card(backgroundColor: UIColor(named: "XYBackground")!)
    
    var titleLabel: Label?
    var separators = [SeparatorLine]()
    var buttons = [UIButton]()
    var fields = [UIView]()
    var externalButtons = [UIButton]()
    
    var onCompletion: (([String]) -> Void)?
    
    // MARK: - PROPERTIES
    
    var tapEscapable: Bool = true
    var textFieldsRequiredForButton: Bool = false
    
    // MARK: - INITIALISERS
    
    init() {
        super.init(frame: .zero)
        
        addSubview(blurEffectView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedBlurView))
        blurEffectView.addGestureRecognizer(gesture)
        
        addSubview(blurEffectView)
        addSubview(card)
        
        blurEffectView.alpha = 0.0
        card.alpha = 0.0
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFECYCLE
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let bounds = superview?.bounds else {
            return
        }
        frame = bounds
    }
    
    override func layoutSubviews() {
        guard !animating else {
            return
        }
        
        super.layoutSubviews()
        
        blurEffectView.frame = bounds
        
        let cardWidth = (superview?.width ?? 375) - 48
        
        if let titleLabel = titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: (cardWidth - titleLabel.width)/2,
                y: 14,
                width: titleLabel.width,
                height: titleLabel.height
            )
        }
        
        var previousY:CGFloat = titleLabel?.bottom ?? 0
        for field in fields {
            var height: CGFloat = 80
            
            if field is UITextView {
                height += CGFloat((field as! UITextView).textContainer.maximumNumberOfLines) * 15
            } else if field is UIButton {
                (field as! UIButton).sizeToFit()
                height = field.height
            } else if field is UILabel {
                if let text = (field as! UILabel).text {
                    let boundingRect = text.boundingRect(
                        with: CGSize(width: cardWidth - 20, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        attributes: [.font: (field as! UILabel).font],
                        context: nil
                    )
                    
                    height = boundingRect.height
                }
            }
            
            field.frame = CGRect(
                x: 16,
                y: previousY + 14,
                width: cardWidth - 32,
                height: height
            )
            
            previousY = field.bottom
        }
        
        for button in buttons {
            
            if let button = button as? Button, button.style == .text {
                if let index = buttons.filter({($0 as! Button).style == .text}).firstIndex(of: button) {
                    separators[index].frame = CGRect(x: 0, y: previousY + 7, width: cardWidth, height: 1)
                }
                
                button.frame = CGRect(
                    x: 0,
                    y: previousY + 7,
                    width: cardWidth,
                    height: 50.77
                )
                
                previousY = button.bottom
            } else {
                button.sizeToFit()
                button.frame = CGRect(
                    x: (cardWidth - button.width)/2,
                    y: previousY + 14,
                    width: button.width,
                    height: button.height
                )
                button.layer.cornerRadius = button.height/2
                
                previousY = button.bottom
            }
        }
        
        let lastButtonIsEmbedded = (buttons.last) != nil && ((buttons.last)! as! Button).style == .text
        let cardHeight = (buttons.last?.bottom ?? fields.last?.bottom ?? titleLabel?.bottom ?? 0)
            + (lastButtonIsEmbedded ? 0 : 14)
        
        card.frame = CGRect(
            x: (width - cardWidth)/2,
            y: (height - cardHeight)/2,
            width: cardWidth,
            height: cardHeight
        )
        
        for button in externalButtons {
            
            button.sizeToFit()
            button.frame = CGRect(
                x: (width - button.width)/2,
                y: card.bottom + (height - card.bottom)/2 - button.height/2,
                width: button.width,
                height: button.height
            )
            button.layer.cornerRadius = button.height/2
        }
    }
    
    // MARK: - USAGE FUNCTIONS
    
    public func appear() {
        
        card.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.3) {
            self.card.transform = .identity
            self.card.alpha = 1.0
            
            self.blurEffectView.alpha = 1.0
        }
    }
    
    var animating = false
    public func disappear() {
        guard !animating else {
            return
        }
        animating = true
        
        HapticsManager.shared.vibrateImpact(for: .soft)
        
        UIView.animate(withDuration: 0.3) {
            self.card.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.card.alpha = 0.0
            
            self.blurEffectView.alpha = 0.0
        } completion: { (done) in
            if done {
                self.transform = .identity
                self.removeFromSuperview()
                self.animating = false
            }
        }
    }
    
    // MARK: - CONFIG FUNCTIONS
    
    public func setTitle(text: String, isGradient: Bool = false) {
        
        titleLabel = Label(text, style: .title, fontSize: 20)
        
        if isGradient {
            titleLabel!.applyGradient(gradientColours: Global.xyGradient)
        }
        
        card.addSubview(titleLabel!)
        
    }
    
    public func addTextWithBoldInRange(text: String, range: NSRange) {
        let label = Label(style: .body)
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.setText(text, applyingBoldInRange: range)
        
        card.addSubview(label)
        fields.append(label)
    }
    
    public func addText(text: String, font: UIFont = UIFont(name: "Raleway-Medium", size: 16)!) {
        let label = Label(text, style: .body)
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .center
        
        card.addSubview(label)
        fields.append(label)
    }
    
    public func addTextInputField(placeholderText: String, maxChars: Int, numLines: Int, font: UIFont = UIFont(name: "Raleway-Medium", size: 16)!) {
        let textField = TextField(placeholder: placeholderText, style: .card, maxChars: maxChars, numLines: numLines, font: font)
        textField.delegate = self
        
        card.addSubview(textField)
        fields.append(textField)
    }
    
    public func addButtonField(image: UIImage? = nil, buttonText: String, font: UIFont? = nil, onTap: (() -> Void)? = nil) {
        let button = Button(image: image, title: buttonText, style: .card, font: font, paddingVertical: 16, paddingHorizontal: 16)
        button.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        button.tintColor = UIColor(named: "XYTint")
//        button.setBackgroundColor(color: UIColor(named: "XYBackground")!, forState: .normal)
        
        if let onTap = onTap {
            button.addAction {
                HapticsManager.shared.vibrateImpact(for: .rigid)
                onTap()
            }
        }
        
        card.addSubview(button)
        fields.append(button)
    }
    
    public func addCompletionButton(
        buttonText: String,
        backgroundColor: UIColor = UIColor(named: "XYCard")!,
        textColor: UIColor = UIColor(named: "XYTint")!,
        icon: UIImage? = nil,
        style: ButtonStyle,
        font: UIFont? = nil,
        closeOnTap: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        switch style {
        case .action(let style):
            let button = Button(image: icon, title: buttonText, style: style, font: font)
            
            button.setTitleColor(textColor, for: .normal)
            
            card.addSubview(button)
            buttons.append(button)
            
            button.isEnabled = !textFieldsRequiredForButton
            
            button.addAction {
                onTap?()
                HapticsManager.shared.vibrateImpact(for: .light)
                if closeOnTap {
                    if self.onCompletion != nil {
                        self.onCompletion!(self.fields.filter({$0 is UITextView}).compactMap({($0 as! UITextView).text}))
                    }
                    self.disappear()
                }
            }
        case .embedded:
            let separatorLine = SeparatorLine()
            
            card.addSubview(separatorLine)
            separators.append(separatorLine)
            
            let button = Button(title: buttonText, style: .text)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = font ?? UIFont(name: "Raleway-Medium", size: 20)
            
            card.addSubview(button)
            buttons.append(button)
            
            button.addAction {
                onTap?()
                HapticsManager.shared.vibrateImpact(for: .light)
                if closeOnTap {
                    if self.onCompletion != nil {
                        self.onCompletion!(self.fields.filter({$0 is UITextField}).compactMap({($0 as! UITextField).text}))
                    }
                    self.disappear()
                }
            }
        }
    }
    
    public func addExternalButton(
        buttonText: String,
        buttonIcon: UIImage? = nil,
        backgroundColor: UIColor = UIColor(named: "XYCard")!,
        textColor: UIColor = UIColor(named: "XYTint")!,
        font: UIFont? = nil,
        closeOnTap: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        
        let button = Button(title: buttonText, style: .roundButton(backgroundColor: backgroundColor), font: font, paddingVertical: 5, paddingHorizontal: 10)
        
        button.setTitleColor(textColor, for: .normal)
        
        addSubview(button)
        externalButtons.append(button)
        
        button.addAction {
            onTap?()
            
            if closeOnTap {
                if self.onCompletion != nil {
                    self.onCompletion!(self.fields.filter({$0 is UITextField}).compactMap({($0 as! UITextField).text}))
                }
                self.disappear()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textFieldsRequiredForButton {
            var fieldsFilled = true
            
            fields.filter({$0 is TextField}).forEach({ fieldsFilled = fieldsFilled && ($0 as! TextField).text.count > 0 })
            
            buttons.forEach({ $0.isEnabled = fieldsFilled })
        }
    }
    
    @objc private func tappedAnywhere() {
        fields.filter({$0 is TextField}).forEach({ ($0 as! TextField).resignFirstResponder() })
    }
    
    @objc private func tappedBlurView() {
        fields.filter({$0 is TextField}).forEach({ ($0 as! TextField).resignFirstResponder() })
        
        if tapEscapable {
            disappear()
        }
    }
    
}
