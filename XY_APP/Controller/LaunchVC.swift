//
//  LaunchVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/01/2021.
//

import UIKit

class LaunchVC: UIViewController {
   
    private let imageView: UIImageView = {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 88, height: 47))
        imageView.image = UIImage(named: "LogoXY")
        return imageView
    
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    
    private func animate(){
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            self.imageView.frame =  CGRect(x: -(diffX/2),
                                           y: diffY/2,
                                           width: size,
                                           height: size
            )
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
        }, completion: {done in
            if done {
                self.performSegue(withIdentifier: "segueToLogin", sender: self)
            }
        })
     
    }
   
}
