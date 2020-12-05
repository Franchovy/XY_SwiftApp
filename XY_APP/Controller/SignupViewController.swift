//
//  ViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit




struct SessionTokenResponse: Decodable {
    let url: URL
}

class SignupViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var signupButton: UIButton!
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        

        self.hideKeyboardWhenTappedAround()
        
        signupButton.layer.cornerRadius = 8
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor.white.cgColor
        usernameTextField.layer.cornerRadius = 8
        gradientView.layer.cornerRadius = 20
        
    }
    
    // UI Textfield reference outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    // Error notification reference outlets
    @IBOutlet weak var signupErrorLabel: UILabel!
    
    @IBAction func signupButton(_ sender: Any)  {
        // Get data from textfields
        let usernameText = usernameTextField.text
        let emailPhoneText = emailPhoneTextField.text
        let passwordText = passwordTextField.text
        let repeatPasswordText = repeatPasswordTextField.text
        
        usernameTextField.endEditing(true)
        emailPhoneTextField.endEditing(true)
        passwordTextField.endEditing(true)
        repeatPasswordTextField.endEditing(true)
        
        // Checks on signup data
        if (passwordText != repeatPasswordText) {
            return
        }
        var signup = Signup()
        signup.validateSignupForm(username: usernameText!, password: passwordText!, email: emailPhoneText!, phoneNumber: "")
        
        // Send signup request
        signup.requestSignup { result in
            switch result {
            case .success(let message):
                print("Signup Success: ", message)
                // Segue to home screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "InterestsPage")
                self.show(secondVC, sender: self)
                
            case .failure(let error):
                print("Signup failure: ", error)
                self.signupErrorLabel.isHidden = false
            }
        }
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
        if (fabs(x) > fabs(y)) {
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


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
