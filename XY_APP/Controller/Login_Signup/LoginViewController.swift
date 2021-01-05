//
//  LoginViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameEmailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginGradientView: UIView!
    
    override func viewDidLoad() {
        loginButton.layer.cornerRadius = 8
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 8
        loginGradientView.layer.cornerRadius = 20
        
        loadingIcon.isHidden = true
        
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = usernameEmailPhoneTextField.text, let password = passwordTextField.text {
            
            loadingIcon.isHidden = false
            loadingIcon.startAnimating()
            
            Firebase.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                self.loadingIcon.isHidden = true
                self.loadingIcon.stopAnimating()
                
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        // HANDLE ERRORS
                        if errCode == .userNotFound || errCode == .wrongPassword {
                            self.displayError(errorText: "Login incorrect!")
                        }
                    }
                    return
                }
                // Successful login
                guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
                
                // Load profile data
                let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
                print("Fetching profile for id: \(uid)")
                
                document.getDocument { documentSnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let documentSnapshot = documentSnapshot {
                        let xyname = documentSnapshot["xyname"] as! String
                        let timestamp = documentSnapshot["timestamp"] as! Firebase.Timestamp
                        let xp = documentSnapshot["xp"] as! Int
                        let level = documentSnapshot["level"] as! Int
                        
                        UserFirebaseData.user = UserData(
                            xyname: xyname,
                            timestamp: Date(timeIntervalSince1970: TimeInterval(timestamp.seconds)),
                            xp: xp,
                            level: level)
                        print("User data loaded from firebase: \(UserFirebaseData.user)")
                        
                        // Segue to main
                        self.performSegue(withIdentifier: "LoginToProfile", sender: self)
                    }
                }
            }
        }
    }
    
    fileprivate func displayError(errorText: String) {
        errorLabel.isHidden = false
        errorLabel.text = "⚠️ " + errorText
    }
}

@IBDesignable
class loginGradientView: UIView {
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
            gradientLayer.cornerRadius = 8
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
            // extrapolate y to unit length
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }
    
    // transform point in unit space to gradient space
    private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
        // input point is in signed unit space: (-1,-1) to (1,1)
        // convert to gradient space: (0,0) to (1,1), with flipped Y axis
        return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
    }
    
    // return the opposite point in the signed unit square
    private func oppositePoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }
}
