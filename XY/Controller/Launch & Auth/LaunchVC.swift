//
//  LaunchVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/01/2021.
//

import UIKit
import FirebaseAuth

class LaunchVC: UIViewController {
    
    static let identifier = "LaunchVC"
   
    private let imageView: UIImageView = {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 88, height: 47))
        imageView.image = UIImage(named: "LogoXY")
        return imageView
    
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        
        view.backgroundColor = UIColor(named: "Black")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center

    }
    
    var segueToPerformOnAnimationFinished = "segueToLogin"
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check for login
        if let user = Auth.auth().currentUser {
            self.segueToPerformOnAnimationFinished = "segueToMain"
        } else {
            if let notFirstTimeUse = UserDefaults.standard.value(forKeyPath: "notFirstTimeUse") as? Bool, notFirstTimeUse {
                segueToPerformOnAnimationFinished = "segueToLogin"
            } else {
                segueToPerformOnAnimationFinished = "segueToSignup"
            }
        }
        
        DispatchQueue.main.async {
            self.animate()
        }

    }
    
    private func animate(){
        UIView.animate(withDuration: 0.8, animations: {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            self.imageView.frame =  CGRect(x: -(diffX/2),
                                           y: diffY/2,
                                           width: size,
                                           height: size
            )
        })
        
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.alpha = 0
        }, completion: { done in
            if done {
                UserDefaults.standard.set(true, forKey: "notFirstTimeUse")
                
                let timer = Timer(timeInterval: TimeInterval(1.0), repeats: false, block: { _ in
                    self.performSegue(withIdentifier: self.segueToPerformOnAnimationFinished, sender: self)
                })
                timer.fire()
            }
        }
        )
     
    }
   
}
