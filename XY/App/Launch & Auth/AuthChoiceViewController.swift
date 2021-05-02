//
//  AuthChoiceViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit
import Hero

class AuthChoiceViewController: UIViewController {

    private let logo = UIImageView(image: UIImage(named: "XYNavbarLogo"))
    
    private let titleLabel = GradientLabel(text: "Ready, Play, XY!", fontSize: 40, gradientColours: Global.darkModeBackgroundGradient)
    
    private let signupButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let loginButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        isHeroEnabled = true
        titleLabel.heroID = "titleLabel"
        
        view.layer.cornerRadius = 15
        
        view.backgroundColor = UIColor(named: "Black")
        
        loginButton.setGradient(Global.xyGradient)
        signupButton.setGradient(Global.xyGradient)
        loginButton.setBackgroundColor(color: UIColor(named: "Black")!)
        
        navigationItem.hidesBackButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        
        loginButton.addTarget(self, action: #selector(loginChoicePressed), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupChoicePressed), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logo.frame = CGRect(
            x: (view.width - 50.95)/2,
            y: view.safeAreaInsets.top,
            width: 50.95,
            height: 27
        )
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (view.width - titleLabel.width)/2,
            y: view.height / 4 - 50,
            width: titleLabel.width,
            height: 50
        )
        
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

    @objc private func loginChoicePressed() {
        HapticsManager.shared.vibrate(for: .success)
        
        let vc = NewLoginViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .pageIn(direction: .left)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func signupChoicePressed() {
        HapticsManager.shared.vibrate(for: .success)
        
        let vc = NewSignupViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .pageIn(direction: .left)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
