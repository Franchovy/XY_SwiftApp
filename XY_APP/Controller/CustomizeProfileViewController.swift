//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    #if !targetEnvironment(simulator)
    let imagePicker = UIImagePickerController()
    #endif
    
    #if !targetEnvironment(simulator)
    let imagePicker = UIImagePickerController()
    #endif
    
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
        
        #if !targetEnvironment(simulator)
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        #endif
    }

    @IBAction func editProfileButton(_ sender: UIButton) {
        // Choose or take a photo
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

        
        //Camera should only be used not in the simulator
        #if !targetEnvironment(simulator)
        present(imagePicker, animated: true, completion: nil)
        #endif
        // Set new profile image
        let newProfileImage = UIImage(named:"profile")!
        // Upload the photo - save photo ID
        let imageManager = ImageManager()
        imageManager.uploadImage(image: newProfileImage, completionHandler: { result in
            print("Uploaded profile image with response: ", result.message)
            let imageId = result.id
            // Set profile to use this photo ID
            Profile.sendEditProfileRequest(completion: {result in
                switch result {
                case .success(let message):
                    print("Successfully edited profile: ", message)
                case .failure(let error):
                    print("Error editing profile: ", error)
                }
            })
        })
    }
}
