//
//  ProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 03/12/2020.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var buttonsConsole: UIView!
    @IBOutlet weak var profileConteiner: UIView!
    @IBOutlet weak var coverPicture: UIImageView!
    
    override func viewDidLoad() {
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
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
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        // nav bar logo
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let profileImageChoosen = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = profileImageChoosen
            print("Image chosen!")
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func editProfileImagePresed(_ sender: AnyObject) {
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
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}



