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
    }
    
    // UI Textfield reference outlets

    @IBOutlet weak var emailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var xyNameTextField: UITextField!
    
    
    // Error notification reference outlets
    @IBOutlet weak var signupErrorLabel: UILabel!
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        if let email = emailPhoneTextField.text, let password = passwordTextField.text {
            
            loadingIcon.isHidden = false
            loadingIcon.startAnimating()
            
            // Create use authenticated
            Firebase.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e)
                    return
                }
                if let uid = authResult?.user.uid, let xyname = self.xyNameTextField.text {
                    // Set user data in user firestore table after signup
                    let newDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
                    
                    newDocument.setData([
                            "xyname" : xyname,
                            "timestamp": FieldValue.serverTimestamp(),
                            "level": 0,
                            "xp": 0
                        ]
                    ) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        //Navigate to Profile
                        
                        self.loadingIcon.isHidden = true
                        self.loadingIcon.stopAnimating()
                        self.performSegue(withIdentifier: "fromSignupToFlow", sender: self)
                    }
                } else {
                    fatalError()
                }
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


