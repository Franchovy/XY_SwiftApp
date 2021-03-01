//
//  AuthChoiceViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit

class AuthChoiceViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let signupButtonGradient:CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        return l
    }()
    private let signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let loginShape: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.masksToBounds = false
        shape.strokeColor = UIColor.red.cgColor
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    private let loginButtonGradient = CAGradientLayer()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.setBackgroundColor(color: UIColor(named:"tintColor")!, forState: .normal)
//        button.setBackgroundColor(color: .lightGray, forState: .highlighted)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let xyGradient:[UIColor] = [UIColor(0xFF0062), UIColor(0x0C98F6)]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "Black")
        
        loginButtonGradient.colors = xyGradient.map({ $0.cgColor })
        signupButtonGradient.colors = xyGradient.map({ $0.cgColor })
        
        loginButton.layer.addSublayer(loginButtonGradient)
        signupButton.layer.insertSublayer(signupButtonGradient, at: 0)
        
        view.addSubview(loginButton)
        view.addSubview(signupButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton.addTarget(self, action: #selector(signUpGradientButtonTouchDown), for: .touchDown)
        signupButton.addTarget(self, action: #selector(signUpGradientButtonTouchUp), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let buttonWidth:CGFloat = 241
        let buttonHeight:CGFloat = 54
        let marginFromCenter:CGFloat = 14
        
        signupButton.frame = CGRect(
            x: (view.width - buttonWidth)/2,
            y: view.height/2 - buttonHeight - marginFromCenter,
            width: buttonWidth,
            height: buttonHeight
        )
        signupButton.layer.cornerRadius = buttonHeight/2
        
        loginButton.frame = CGRect(
            x: (view.width - buttonWidth)/2,
            y: view.height/2 + marginFromCenter,
            width: buttonWidth,
            height: buttonHeight
        )
        loginButton.layer.cornerRadius = buttonHeight/2
        
        signupButtonGradient.frame = signupButton.bounds
        loginButtonGradient.frame = loginButton.bounds
        
        loginShape.path = UIBezierPath(roundedRect: self.loginButton.bounds.insetBy(dx: 1, dy: 1), cornerRadius: buttonHeight/2).cgPath
        loginButtonGradient.mask = loginShape
        
        loginButton.applyshadowWithCorner(containerView: loginButton, cornerRadious: buttonHeight/2, shadowOffset: CGSize(width: 0, height: 3), shadowRadius: 6)
        signupButton.applyshadowWithCorner(containerView: signupButton, cornerRadious: buttonHeight/2, shadowOffset: CGSize(width: 0, height: 3), shadowRadius: 6)
    }
    
    @objc private func signUpGradientButtonTouchDown() {
        signupButtonGradient.colors = xyGradient.map({
            $0.withAlphaComponent(0.5).cgColor
        })
    }
    
    @objc private func signUpGradientButtonTouchUp() {
        signupButtonGradient.colors = xyGradient.map({ $0.cgColor })
    }
}
