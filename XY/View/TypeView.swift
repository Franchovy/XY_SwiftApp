//
//  TypeView.swift
//  XY
//
//  Created by Maxime Franchot on 17/02/2021.
//

import UIKit

protocol TypeViewDelegate {
    func sendButtonPressed(text: String)
    func emojiButtonPressed()
    func imageButtonPressed()
}


class TypeView: UIView {

    private let emojiButtonGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(0x3F63F7).cgColor,
            UIColor(0x58A5FF).cgColor
        ]
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
        gradientLayer.locations = [0, 1]
        return gradientLayer
    }()
    
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let emojiButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: UIColor(0x3F63F7), forState: .normal)
        button.setImage(UIImage(systemName: "face.smiling")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: UIColor(0x3F63F7), forState: .normal)
        button.setImage(UIImage(systemName: "paperplane.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    private let typeTextField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "tintColor")!.cgColor
        textView.layer.cornerRadius = 15
        textView.font = UIFont(name: "HelveticaNeue", size: 14)
        textView.textContainerInset = UIEdgeInsets(top: 9, left: 4, bottom: 7, right: 27)
        return textView
    }()

    var delegate: TypeViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        cameraButton.layer.insertSublayer(emojiButtonGradient, at: 0)
        cameraButton.layer.insertSublayer(cameraImageView.layer, above: nil)
        addSubview(cameraButton)
        addSubview(emojiButton)
        addSubview(typeTextField)
        addSubview(sendButton)
        
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let buttonSize:CGFloat = 38
        cameraButton.frame = CGRect(
            x: 15,
            y: (height-buttonSize)/2,
            width: buttonSize,
            height: buttonSize
        )
        emojiButtonGradient.frame = cameraButton.bounds
        cameraImageView.frame = cameraButton.bounds.insetBy(dx: 5, dy: 5)
        
        emojiButton.frame = CGRect(
            x: cameraButton.right + 5,
            y: (height-buttonSize)/2,
            width: buttonSize,
            height: buttonSize
        )
        
        typeTextField.frame = CGRect(
            x: emojiButton.right + 5,
            y: (height-buttonSize)/2,
            width: width - (emojiButton.right + 5) - 15,
            height: buttonSize
        )
        
        let sendButtonSize: CGFloat = 22.5
        sendButton.frame = CGRect(
            x: typeTextField.right - sendButtonSize - 10.5,
            y: 8,
            width: sendButtonSize,
            height: sendButtonSize
        )
    }
    
    @objc func sendButtonPressed() {
        guard let text = typeTextField.text, text != "" else {
            return
        }
        
        delegate?.sendButtonPressed(text: text)
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        
        return typeTextField.resignFirstResponder()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                typeTextField.layer.borderColor = UIColor(named: "tintColor")?.cgColor
            }
        }
    }
}
