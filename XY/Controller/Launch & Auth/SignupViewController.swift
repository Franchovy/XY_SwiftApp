//
//  ViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var signupButton: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton.layer.cornerRadius = 8
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor.white.cgColor
        gradientView.layer.cornerRadius = 20
        
        loadingIcon.isHidden = true
        
        xyNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        
        passwordTextField.addTarget(self, action: #selector(securePassword), for: .editingDidBegin)
        repeatPasswordTextField.addTarget(self, action: #selector(secureRepeatPassword), for: .editingDidBegin)

        let tapAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapAnywhereGesture)
        
        xyNameTextField.addTarget(self, action: #selector(xyNameDidPressReturn), for: .primaryActionTriggered)
        emailTextField.addTarget(self, action: #selector(emailPhoneDidPressReturn), for: .primaryActionTriggered)
        passwordTextField.addTarget(self, action: #selector(passwordDidPressReturn), for: .primaryActionTriggered)
        repeatPasswordTextField.addTarget(self, action: #selector(repeatPasswordDidPressReturn), for: .primaryActionTriggered)
    }
    
    // UI Textfield reference outlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var xyNameTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    
    // Error notification reference outlets
    @IBOutlet weak var signupErrorLabel: UILabel!
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        tappedAnywhere()
        
        guard xyNameTextField.text != "" else {
            xyNameTextField.shake()
            presentError(errorText: "Please fill in the XYName field")
            return
        }
        
        guard emailTextField.text != "" else {
            emailTextField.shake()
            presentError(errorText: "Please fill in the email field")
            return
        }
        
        guard passwordTextField.text != "" else {
            passwordTextField.shake()
            presentError(errorText: "Please fill in the password field")
            return
        }
        
        guard passwordTextField.text == repeatPasswordTextField.text else {
            passwordTextField.clear(self)
            repeatPasswordTextField.clear(self)
            passwordTextField.shake()
            repeatPasswordTextField.shake()
            presentError(errorText: "Passwords do not match.")
            return
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            loadingIcon.isHidden = false
            loadingIcon.startAnimating()
            
            if let xyname = self.xyNameTextField.text {
                AuthManager.shared.signUp(xyname: xyname, email: email, password: password) { result in
                    switch result {
                    case .success(_):
                        self.signupErrorLabel.isHidden = true
                        self.loadingIcon.isHidden = true
                        self.loadingIcon.stopAnimating()
                        self.performSegue(withIdentifier: "fromSignupToFlow", sender: self)
                        
                    case .failure(let error):
                        print("Error creating profile: \(error)")
                        self.signupErrorLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    private func presentError(errorText: String) {
        signupErrorLabel.isHidden = false
        signupErrorLabel.text = "⚠️ " + errorText
    }
    
    @objc private func tappedAnywhere() {
        for view in [
            view,
            emailTextField,
            xyNameTextField,
            passwordTextField,
            repeatPasswordTextField
        ] {
            view?.resignFirstResponder()
        }
    }
    
    @objc private func xyNameDidPressReturn() {
        emailTextField.becomeFirstResponder()
    }
    
    @objc private func emailPhoneDidPressReturn() {
        passwordTextField.becomeFirstResponder()
    }
    
    @objc private func passwordDidPressReturn() {
        repeatPasswordTextField.becomeFirstResponder()
    }

    @objc private func repeatPasswordDidPressReturn() {
        signupButtonPressed(signupButton)
    }
    
    @objc private func securePassword() {
        passwordTextField.isSecureTextEntry = true
    }
    
    @objc private func secureRepeatPassword() {
        repeatPasswordTextField.isSecureTextEntry = true
    }
}

extension SignupViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        signupErrorLabel.isHidden = true
        signupErrorLabel.text = "⚠️ Signup failed!"
    }
}


@IBDesignable
class GradientView: UIView {
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    // the gradient angle, in degrees anticlockwise from 0 (east/right)
    @IBInspectable var angle: CGFloat = 270 {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
            gradientLayer.frame = bounds
            gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
            
            // Calculate start and end point positions
            let (start, end) = gradientPointsForAngle(self.angle)
            // Set start and end points
            gradientLayer.startPoint = start
            gradientLayer.endPoint = end
            
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = 15
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    // create vector pointing in direction of angle
    private func gradientPointsForAngle(_ angle: CGFloat) -> (CGPoint, CGPoint) {
        // get vector start and end points
        let end = pointForAngle(angle)
        //let start = pointForAngle(angle+180.0)
        let start = oppositePoint(end)
        // convert to gradient space
        let p0 = transformToGradientSpace(start)
        let p1 = transformToGradientSpace(end)
        return (p0, p1)
    }
    
    // get a point corresponding to the angle
    private func pointForAngle(_ angle: CGFloat) -> CGPoint {
        // convert degrees to radians
        let radians = angle * .pi / 180.0
        var x = cos(radians)
        var y = sin(radians)
        // (x,y) is in terms unit circle. Extrapolate to unit square to get full vector length
        if (abs(x) > abs(y)) {
            // extrapolate x to unit length
            x = x > 0 ? 1 : -1
            y = x * tan(radians)
        } else {
            
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }
    
    
    private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
        
        return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
    }
    
    
    private func oppositePoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }
}


