//
//  UnicornViewController.swift
//  XY
//
//  Created by Maxime Franchot on 28/03/2021.
//

import UIKit

class UnicornViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "XYLogo"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-ExtraBold", size: 35)
        label.textColor = UIColor(named: "XYWhite")
        label.text = "Insane update in:"
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "unicorn"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let countdownLabel: CountdownLabel = {
        let countdownLabel = CountdownLabel()
        countdownLabel.font = UIFont(name: "Raleway-ExtraBold", size: 72)
        countdownLabel.textColor = UIColor(named: "XYYellow")
        countdownLabel.setDeadline(countDownTo: Date(timeIntervalSince1970: 1617508800))
        countdownLabel.setSpacer(" ")
        return countdownLabel
    }()
    
    private let labelStack: LabelStackView = {
        let labelStack = LabelStackView(labels: ["Days", "Hours", "Minutes", "Seconds"])
        labelStack.setColor(UIColor(named: "XYWhite"))
        labelStack.setFont(UIFont(name: "Raleway-ExtraBold", size: 15))
        labelStack.alignment = .fill
        labelStack.spacing = 0
        labelStack.distribution = .equalCentering
        return labelStack
    }()
    
    private let dropMailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-ExtraBold", size: 15)
        label.textColor = UIColor(named: "XYWhite")
        label.text = "Drop your best friend's email"
        return label
    }()
    
    private let textField: XYTextField = {
        let textField = XYTextField()
        textField.font = UIFont(name: "Raleway-Regular", size: 12)
        textField.placeholder = "My best friend's email"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.textAlignment = .center
        textField.tintColor = .white
        return textField
    }()
    
    private let gradientBackground: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(0x0C98F6).cgColor, UIColor(0xFF0062).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.45, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.55, y: 1.0)
        return gradientLayer
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.layer.addSublayer(gradientBackground)
        
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(countdownLabel)
        view.addSubview(labelStack)
        view.addSubview(dropMailLabel)
        view.addSubview(textField)
        
        textField.setRightButton(side: .right, image: UIImage(systemName: "paperplane.fill"), target: self, selector: #selector(didPressBestFriendMail))
        textField.rightViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientBackground.frame = view.bounds
        
        
        logoImageView.frame = CGRect(
            x: (view.width - 95.41)/2,
            y: 47.85,
            width: 95.41,
            height: 66.15
        )
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (view.width - titleLabel.width)/2,
            y: 178,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        let imageSize: CGFloat = 201
        imageView.frame = CGRect(
            x: (view.width - imageSize)/2,
            y: titleLabel.bottom + 18,
            width: imageSize,
            height: imageSize
        )
        
        countdownLabel.sizeToFit()
        countdownLabel.frame = CGRect(
            x: (view.width - countdownLabel.width)/2,
            y: imageView.bottom,
            width: view.width,
            height: countdownLabel.height
        )
        
//        gradientBackground.mask = countdownLabel.layer
        
        let stackWidth = view.width - 24
        labelStack.frame = CGRect(
            x: 34,
            y: countdownLabel.bottom + 18,
            width: view.width - 24 - 34,
            height: 18
        )
        
        dropMailLabel.sizeToFit()
        dropMailLabel.frame = CGRect(
            x: (view.width - dropMailLabel.width)/2,
            y: labelStack.bottom + 78,
            width: dropMailLabel.width,
            height: dropMailLabel.height
        )
        
        textField.frame = CGRect(
            x: (view.width - 255)/2,
            y: dropMailLabel.bottom + 11,
            width: 255,
            height: 46
        )
        textField.layer.cornerRadius = 23
    }
    
    @objc private func didPressBestFriendMail() {
        if textField.text != nil, textField.text != "" {
//            register mail & this user to backend
            print("Invited: \(textField.text)")
        }
    }
}
