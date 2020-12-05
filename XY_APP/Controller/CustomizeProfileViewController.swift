//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController {
    
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

    @IBAction func profileImageButtonPressed(_ sender: Any) {
        // Choose or take a photo
        
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
