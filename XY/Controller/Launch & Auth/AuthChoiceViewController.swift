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
    
    private let signupButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let loginButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        return button
    }()
    
    private let xyGradient:[UIColor] = [UIColor(0xFF0062), UIColor(0x0C98F6)]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "Black")
        
        loginButton.setGradient(xyGradient)
        signupButton.setGradient(xyGradient)
        
        view.addSubview(loginButton)
        view.addSubview(signupButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

}
