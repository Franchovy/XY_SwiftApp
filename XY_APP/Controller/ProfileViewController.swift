//
//  ProfileViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/12/2020.
//

import UIKit

class ProfileViewController : UIViewController {
    
    @IBOutlet weak var coverPicture: UIImageView!
    @IBOutlet weak var profileCoverImage: UIImageView!
    @IBOutlet weak var profileDash: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCoverImage.layer.cornerRadius = 15.0
        profileCoverImage.layer.shadowColor = UIColor.black.cgColor
        profileCoverImage.layer.shadowOffset = CGSize(width:1, height:1)
        profileCoverImage.layer.shadowRadius = 2
        profileCoverImage.layer.shadowOpacity = 1.0
        
        profileDash.layer.cornerRadius = 15.0
        profileDash.layer.shadowColor = UIColor.black.cgColor
        profileDash.layer.shadowOffset = CGSize(width:1, height:1)
        profileDash.layer.shadowRadius = 2
        profileDash.layer.shadowOpacity = 1.0
        
        followButton.layer.cornerRadius = 5.0
        followButton.layer.shadowColor = UIColor.black.cgColor
        followButton.layer.shadowOffset = CGSize(width:1, height:1)
        followButton.layer.shadowRadius = 2
        followButton.layer.shadowOpacity = 1.0
        
        
    }
    
    
    @IBAction func uploadImageButtonPressed(_ sender: Any) {
        // Run a Async thread to upload file in order not to slow down the user experience
        //DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let image = coverPicture.image {
                Profile(username:"test").uploadImageOne(image: image, completion: { result in
                    switch result {
                    case .success(let message):
                        print("Image Upload Success!")
                    case .failure(let error):
                        print("Image Upload Failure.")
                    }
                })
            }
        //}
    }
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
    }
    
}
