//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var containerOne: UIView!
    
    override func viewDidLoad() {
        
        
        containerOne.layer.cornerRadius = 15.0
        
        imagePicker.delegate = self    //
        imagePicker.sourceType = .camera
       
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}
