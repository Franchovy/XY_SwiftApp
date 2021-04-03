//
//  Prompt.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class Prompt: UIView {
    
    // MARK: - ENUMS
    
    enum ButtonStyle {
        case embedded
        case action
    }
    
    // MARK: - UI PROPERTIES

    var blurEffectView: UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurView)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    var card = Card(backgroundColor: UIColor(named: "XYBackground")!)
    
    var titleLabel: UILabel?
    var buttons = [UIButton]()
    var fields = [UIView]()
    var externalButtons = [UIButton]()
    
    var onCompletion: (([String]) -> Void)?
    
    // MARK: - PROPERTIES
    
    var tapEscapable: Bool = false
    
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
            field.frame = CGRect(
                x: 16,
                y: previousY + 14,
                width: cardWidth - 32,
                height: 80
            )
            
            previousY = field.bottom
        }
        
        for button in buttons {
            
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
        
        let cardHeight = (buttons.last?.bottom ?? fields.last?.bottom ?? titleLabel?.bottom ?? 0)
            + 14
        
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
                y: (height - card.bottom)/2 - button.height/2,
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
    
    public func disappear() {
        
        UIView.animate(withDuration: 0.3) {
            self.card.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.card.alpha = 0.0
            self.blurEffectView.alpha = 0.0
        } completion: { (done) in
            if done {
                self.card.transform = .identity
                self.removeFromSuperview()
            }
        }
    }
    
    // MARK: - CONFIG FUNCTIONS
    
    public func setTitle(text: String, isGradient: Bool = true) {
        if isGradient {
//            titleLabel = GradientLabel(text: text, fontSize: 20, gradientColours: Global.xyGradient)
        } else {
            
        }
        
        titleLabel = Label(text, style: .title, fontSize: 20)
        
        card.addSubview(titleLabel!)
        
    }
    
    public func addText(text: String, font: UIFont = UIFont(name: "Raleway-Medium", size: 16)!) {
        
    }
    
    public func addTextField(placeholderText: String, maxChars: Int, font: UIFont = UIFont(name: "Raleway-Medium", size: 16)!) {
        let textField = TextField(placeholder: placeholderText, style: .card)
        
        card.addSubview(textField)
        fields.append(textField)
    }
    
    public func addButton(
        buttonText: String,
        backgroundColor: UIColor = UIColor(named: "XYCard")!,
        textColor: UIColor = UIColor(named: "XYTint")!,
        icon: UIImage? = nil,
        style: ButtonStyle,
        closeOnTap: Bool = false,
        onTap: (() -> Void)? = nil,
        target: Selector? = nil
    ) {
        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
        
        button.setBackgroundColor(color: backgroundColor, forState: .normal)
        button.setTitleColor(textColor, for: .normal)
        
        card.addSubview(button)
        buttons.append(button)
        
        button.addAction {
            onTap?()
            
            if closeOnTap {
                if self.onCompletion != nil {
                    self.onCompletion!(self.fields.filter({$0 is UITextField}).compactMap({($0 as! UITextField).text}))
                }
                self.disappear()
            }
        }
//        button.addTarget(Selector(, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
//        if style == .action {
//            button.setBackgroundColor(color: backgroundColor, forState: .normal)
//            button.setTitleColor(textColor, for: .normal)
//        } else {
//            button.setTitleColor(textColor, for: .normal)
//            button.frame.size.width = card.width
//        }
    }
    
    public func addExternalButton(
        buttonText: String,
        buttonIcon: UIImage? = nil,
        backgroundColor: UIColor = UIColor(named: "XYCard")!,
        textColor: UIColor = UIColor(named: "XYTint")!,
        closeOnTap: Bool = true,
        onTap: (() -> Void)? = nil,
        target: Selector? = nil
    ) {
        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
        
        button.setBackgroundColor(color: backgroundColor, forState: .normal)
        button.setTitleColor(textColor, for: .normal)
        
        card.addSubview(button)
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
    
    @objc private func tappedBlurView() {
        if tapEscapable {
            disappear()
        }
    }
    
}
