//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController{
    
    // MARK: - PROPERTIES
    
    // Outlets for data
    
    @IBOutlet weak var selectProfilePicture: UIView!
    @IBOutlet weak var selectCoverPicture: UIButton!
    @IBOutlet weak var editXYName: UITextField!
    
    @IBOutlet weak var editProfileCaption: UITextField!
    
    @IBOutlet weak var editFullName: UITextField!
    @IBOutlet weak var editRole: UITextField!
    
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var repeatNewPasswordField: UITextField!
    
    
    // Functionality properties
    
    let imagePicker = UIImagePickerController()
    
    var profileData: Profile.ProfileData?
    
    override func viewDidLoad() {
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        Profile.shared.getProfile(username: Session.shared.username, closure: { result in
            switch result {
            case .success(let profile):
                self.profileData = profile
            case .failure(let error):
                print("Error getting profile data: \(error)")
            }
        })
        
    }
    
    // MARK: - IBActions
    
    
    @IBAction func birthdayButtonPressed(_ sender: Any) {
        
    }
    @IBAction func locationButtonPressed(_ sender: Any) {
        
    }
    @IBAction func websiteButtonPressed(_ sender: Any) {
        
    }
    
    
    
}

class EditProfileCard : UIView {
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layer.cornerRadius = 15.0
    }
}
