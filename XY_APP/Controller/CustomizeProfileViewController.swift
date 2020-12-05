//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController {
    
    @IBOutlet weak var containerOne: UIView!
    
    override func viewDidLoad() {
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        containerOne.layer.cornerRadius = 15.0
        containerOne.layer.shadowColor = UIColor.black.cgColor
        containerOne.layer.shadowOffset = CGSize(width:1, height:1)
        containerOne.layer.shadowRadius = 2
        containerOne.layer.shadowOpacity = 1.0

       
    }

}
