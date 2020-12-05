//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

    @IBAction func editProfileButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
            picker.delegate = self
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                action in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
                action in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
}
