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
        label.text = "The unicorn bites."
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
        countdownLabel.setDeadline(countDownTo: Date(timeIntervalSince1970: 1617890400))
        countdownLabel.setSpacer(" ")
        countdownLabel.adjustsFontSizeToFitWidth = true
        return countdownLabel
    }()
    
    private let labelStack: LabelStackView = {
        let labelStack = LabelStackView(labels: ["Days", "Hours", "Minutes", "Seconds"])
        labelStack.setColor(UIColor(named: "XYWhite"))
        labelStack.setFont(UIFont(name: "Raleway-ExtraBold", size: 15))
        labelStack.alignment = .fill
        labelStack.spacing = 0
        labelStack.distribution = .fillEqually
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
        textField.textColor = .white
        return textField
    }()
    
    private let labelGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.45, y: 0.4)
        gradientLayer.endPoint = CGPoint(x: 0.55, y: 0.6)
        gradientLayer.locations = [0.4, 0.6]
        return gradientLayer
    }()
    
    private let gradientBackground: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        return gradientLayer
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupGradients()
        view.layer.addSublayer(gradientBackground)
        view.layer.addSublayer(labelGradient)
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(countdownLabel)
        view.addSubview(labelStack)
        view.addSubview(dropMailLabel)
        view.addSubview(textField)
        
        textField.setRightButton(side: .right, image: UIImage(systemName: "paperplane.fill"), target: self, selector: #selector(didPressBestFriendMail))
        textField.rightViewMode = .always
        
        let tappedAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tappedAnywhereGesture)
        
        let tappedImageGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tappedImageGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateBackground()
        
        if traitCollection.userInterfaceStyle == .dark {
            animateLabelGradient()
        }
        
        navigationController?.isNavigationBarHidden = true
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
            y: view.width / 3,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        let imageSize: CGFloat = view.width / 2
        imageView.frame = CGRect(
            x: (view.width - imageSize)/2,
            y: titleLabel.bottom + 18,
            width: imageSize,
            height: imageSize
        )
        
        countdownLabel.sizeToFit()
        countdownLabel.frame.size.width = min(view.width - 16, countdownLabel.width)
        countdownLabel.frame = CGRect(
            x: (view.width - countdownLabel.width)/2,
            y: view.height/2,
            width: countdownLabel.width,
            height: countdownLabel.height
        )
        labelGradient.frame = view.bounds
        labelGradient.mask = countdownLabel.layer
        
        labelStack.frame = CGRect(
            x: countdownLabel.left,
            y: countdownLabel.bottom + 9,
            width: countdownLabel.width,
            height: 18
        )
        
        dropMailLabel.sizeToFit()
        dropMailLabel.frame = CGRect(
            x: (view.width - dropMailLabel.width)/2,
            y: (view.height - dropMailLabel.height)*3/4,
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupGradients()
        
        if traitCollection.userInterfaceStyle == .dark {
            animateLabelGradient()
        } else {
            removeLabelAnimation()
        }
    }
    
    private func setupGradients() {
        gradientBackground.colors =
            traitCollection.userInterfaceStyle == .light ?
            [UIColor(0x0C98F6).cgColor, UIColor(0xFF0062).cgColor] :
            [UIColor(0x626263).cgColor, UIColor(0x292A2B).cgColor, UIColor(0x141516).cgColor]
        
        labelGradient.colors =
            traitCollection.userInterfaceStyle == .light ?
            [UIColor(named: "XYYellow")!.cgColor, UIColor(named: "XYYellow")!.cgColor] :
            [UIColor(0xFF0062).cgColor, UIColor(0x0C98F6).cgColor]
    }
    
    private func animateBackground() {
        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.duration = 3.0
        
        startPointAnimation.fromValue = CGPoint(x: 0.5, y: 0.0)
        startPointAnimation.toValue = CGPoint(x: 0.3, y: 0.2)
        
        
        let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
        endPointAnimation.duration = 2.5
        startPointAnimation.duration = 3.0
        
        endPointAnimation.fromValue = CGPoint(x: 0.3, y: 1.0)
        endPointAnimation.toValue = CGPoint(x: 0.7, y: 0.8)
        

        endPointAnimation.fillMode = CAMediaTimingFillMode.forwards
        endPointAnimation.isRemovedOnCompletion = false
        endPointAnimation.autoreverses = true
        endPointAnimation.repeatCount = Float.infinity
        endPointAnimation.timingFunction = .easeInOut
        
        startPointAnimation.fillMode = CAMediaTimingFillMode.forwards
        startPointAnimation.isRemovedOnCompletion = false
        startPointAnimation.autoreverses = true
        startPointAnimation.repeatCount = Float.infinity
        startPointAnimation.timingFunction = .easeInOut
        
        gradientBackground.add(startPointAnimation, forKey: "startPointAnimation")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.gradientBackground.add(endPointAnimation, forKey: "endPointAnimation")
        }
    }
    
    private func animateLabelGradient() {
        let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
        startPointAnimation.fromValue = CGPoint(x: 0.3, y: 0.8)
        startPointAnimation.toValue = CGPoint(x: 0.3, y: 0.9)
        
        let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
        endPointAnimation.duration = 2.5
        startPointAnimation.duration = 3.0
        
        endPointAnimation.fromValue = CGPoint(x: 0.7, y: 0.2)
        endPointAnimation.toValue = CGPoint(x: 0.7, y: 0.1)

        endPointAnimation.fillMode = CAMediaTimingFillMode.forwards
        endPointAnimation.isRemovedOnCompletion = false
        endPointAnimation.autoreverses = true
        endPointAnimation.repeatCount = Float.infinity
        endPointAnimation.timingFunction = .easeInOut
        
        startPointAnimation.fillMode = CAMediaTimingFillMode.forwards
        startPointAnimation.isRemovedOnCompletion = false
        startPointAnimation.autoreverses = true
        startPointAnimation.repeatCount = Float.infinity
        startPointAnimation.timingFunction = .easeInOut
        
        labelGradient.add(startPointAnimation, forKey: "startPointAnimation")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.labelGradient.add(endPointAnimation, forKey: "endPointAnimation")
        }
    }
    
    private func removeLabelAnimation() {
        labelGradient.removeAnimation(forKey: "startPointAnimation")
        labelGradient.removeAnimation(forKey: "endPointAnimation")
    }
    
    @objc private func didPressBestFriendMail(_ sender: UIButton) {
        if let email = textField.text, email != "" {
            
            if isValidEmail(email) {
                sender.isEnabled = false
                InviteService.shared.inviteEmail(email: email) { (success) in
                    if !success {
                        HapticsManager.shared?.vibrate(for: .error)
                        self.textField.shake()
                    } else {
                        HapticsManager.shared?.vibrate(for: .success)
                        self.displayTempLabel(
                            centerPoint: self.textField.center.applying(CGAffineTransform(translationX: 0, y: 40)),
                            labelText: "Added email!",
                            labelColor: UIColor.white
                        )
                        self.textField.text = ""
                    }
                    sender.isEnabled = true
                }
            } else {
                textField.shake()
            }
        }
    }
    
    var popupPrompt: PopupMessageView?
    var blurEffectView: UIVisualEffectView?
    public func popupPrompt(title: String, message: String, confirmText: String, completion: @escaping(() -> Void)) {
        // Add blur
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.0
        view.addSubview(blurEffectView)
        self.blurEffectView = blurEffectView
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedBlurView))
        blurEffectView.addGestureRecognizer(gesture)
        
        UIView.animate(withDuration: 0.2) {
            blurEffectView.alpha = 1.0
        } completion: { (done) in
            if done {
                // Add popup View
                let popupView = PopupMessageView(
                    title: title,
                    message: message,
                    confirmText: confirmText,
                    completion: {
                        UIView.animate(withDuration: 0.2) {
                            blurEffectView.alpha = 0.0
                        } completion: { (done) in
                            if done {
                                self.popupPrompt = nil
                                blurEffectView.removeFromSuperview()
                                self.blurEffectView = nil
                            }
                        }
                        completion()
                    }
                )
                
                popupView.sizeToFit()
                self.view.addSubview(popupView)
                popupView.center = self.view.center
                self.popupPrompt = popupView
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var coolDown = 0
    @objc private func tappedBlurView() {
        coolDown += 1
        
        if let popupPrompt = popupPrompt {
            popupPrompt.scaleAnimate(
                1.0 - (Float(coolDown) * 0.1),
                duration: 0.1
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                popupPrompt.springScaleAnimate(from: 0.9, to: 1.0)
            }
        }
        
        if coolDown > 10 {
            self.popupPrompt?.scaleAnimate(2.0, duration: 0.3)
            
            UIView.animate(withDuration: 0.2) {
                self.blurEffectView?.alpha = 0.0
                self.popupPrompt?.alpha = 0.0
            } completion: { (done) in
                if done {
                    self.popupPrompt?.removeFromSuperview()
                    self.popupPrompt = nil
                    self.blurEffectView?.removeFromSuperview()
                    self.blurEffectView = nil
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.coolDown -= 1
        }
    }
    
    @objc private func tappedAnywhere() {
        textField.resignFirstResponder()
    }
    
    @objc private func tappedImage() {
        
        if PushNotificationManager.shared == nil {
            guard let userId = AuthManager.shared.userId else {
                return
            }
            PushNotificationManager.shared = PushNotificationManager(userID: userId)
        }
        
        PushNotificationManager.shared?.arePushNotificationsEnabled(completion: { (enabled) in
                DispatchQueue.main.async {
                    self.imageView.scaleAnimate(0.9, duration: 0.1)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.imageView.springScaleAnimate(from: 0.9, to: 1.0)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            
                            self.popupPrompt(
                                title: "Don't miss out",
                                message: "An insane update is coming. Get notified.",
                                confirmText: "Enable Notifications") {
                                PushNotificationManager.shared?.registerForPushNotifications()
                            }
                        }
                    }
                }
        })
    }
}
