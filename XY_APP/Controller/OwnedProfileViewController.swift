//
//  ownedProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 12/12/2020.
//

import Foundation
import UIKit

class OwnedProfileViewController :  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var moodView: UIView!
    @IBOutlet weak var buttonConsole: UIView!
    
    override func viewDidLoad() {
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        profileContainer.layer.cornerRadius = 15.0
        profileContainer.layer.shadowColor = UIColor.black.cgColor
        profileContainer.layer.shadowOffset = CGSize(width:1, height:1)
        profileContainer.layer.shadowRadius = 1
        profileContainer.layer.shadowOpacity = 1.0
        
        moodView.layer.cornerRadius = 15.0
        moodView.layer.shadowColor = UIColor.black.cgColor
        moodView.layer.shadowOffset = CGSize(width:1, height:1)
        moodView.layer.shadowRadius = 1
        moodView.layer.shadowOpacity = 1.0
        
        buttonConsole.layer.cornerRadius = 15.0
        buttonConsole.layer.shadowColor = UIColor.black.cgColor
        buttonConsole.layer.shadowOffset = CGSize(width:1, height:1)
        buttonConsole.layer.shadowRadius = 1
        buttonConsole.layer.shadowOpacity = 1.0
        
        
        
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
    }
    @IBAction func cameraNavigationBar(_ sender: UIBarButtonItem) {
        
    }
    
}

