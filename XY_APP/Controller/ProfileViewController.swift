//
//  ProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 03/12/2020.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var buttonsConsole: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileConteiner: UIView!
    @IBOutlet weak var coverPicture: UIImageView!
    
    override func viewDidLoad() {
        
        profileConteiner.layer.cornerRadius = 15.0
        profileConteiner.layer.shadowColor = UIColor.black.cgColor
        profileConteiner.layer.shadowOffset = CGSize(width:1, height:1)
        profileConteiner.layer.shadowRadius = 2
        profileConteiner.layer.shadowOpacity = 1.0
        
        buttonsConsole.layer.cornerRadius = 15.0
        buttonsConsole.layer.shadowColor = UIColor.black.cgColor
        buttonsConsole.layer.shadowOffset = CGSize(width:1, height:1)
        buttonsConsole.layer.shadowRadius = 2
        buttonsConsole.layer.shadowOpacity = 1.0
        
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    @IBAction func submitPostButtonPressed(_ sender: Any) {

    }
    

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        
        
    }
}
