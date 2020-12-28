//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController {
    
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
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
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
                
                DispatchQueue.main.async {
                    // Set placeholders to current
                    if let birthdate = self.profileData?.birthdate {
                        self.datePicker.setDate(birthdate, animated: false)
                    }
                    if let fullName = self.profileData?.fullName {
                        self.editFullName.placeholder = fullName
                    }
                    if let role = self.profileData?.role {
                        self.editRole.text = role
                    }
                    if let caption = self.profileData?.caption {
                        self.editProfileCaption.placeholder = caption
                    }
                }
                
            case .failure(let error):
                print("Error getting profile data: \(error)")
            }
        })
        
        datePickerView.layer.cornerRadius = 15.0
        
    }
    
    // MARK: - IBActions
    
    @IBAction func editCaptionEditingEnded(_ sender: Any) {
        profileData?.caption = editProfileCaption.text
        
        Profile.shared.editProfile(data: profileData!, closure: {
            print("Successfully changed caption")
        })
    }
    
    
    @IBAction func editRoleEditingEnded(_ sender: UITextField) {
        profileData?.role = editRole.text
        
        Profile.shared.editProfile(data: profileData!, closure: {
            print("Successfully changed profile role")
        })
    }
    
    @IBAction func editFullNameEditingEnded(_ sender: UITextField) {
        profileData?.fullName = editFullName.text
        
        Profile.shared.editProfile(data: profileData!, closure: {
            print("Successfully changed full name")
        })
    }
    
    @IBAction func birthdayButtonPressed(_ sender: Any) {
        datePickerView.isHidden = false
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Location", message: "Where can people find you?", preferredStyle: UIAlertController.Style.alert )

        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                //Read TextFields text data
                self.profileData?.location = textField.text
                Profile.shared.editProfile(data: self.profileData!, closure: {
                    print("Successfully edited profile location")
                    //TODO - RELOAD PROFILE
                })
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Your City"
            textField.textColor = .black
        }
        
        alert.addAction(save)
        // Add Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }
    
    @IBAction func websiteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Website", message: "Where can I buy your merch?", preferredStyle: UIAlertController.Style.alert )

        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                //Read TextFields text data
                self.profileData?.website = textField.text
                Profile.shared.editProfile(data: self.profileData!, closure: {
                    print("Successfully edited profile website")
                    //TODO - RELOAD PROFILE
                })
            }
        }

        alert.addTextField { (textField) in
            textField.placeholder = "www.xy.com"
            textField.textColor = .black
        }
        
        alert.addAction(save)
        // Add Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }

    // MARK: - DATE PICKER METHODS
    @IBAction func datePickConfirmPressed(_ sender: Any) {
        let newDate = datePicker.date
        profileData?.birthdate = newDate
        Profile.shared.editProfile(data: profileData!, closure: {
            print("Changed profile data!")
            self.datePickerView.isHidden = true
        })
    }
    @IBAction func datePickCancelPressed(_ sender: Any) {
        datePickerView.isHidden = true
    }
    
    @IBAction func passwordFieldEditingEnded(_ sender: UITextField) {
        
        if newPasswordField.text != "" && currentPasswordField.text != "" && repeatNewPasswordField.text != "" {
            if newPasswordField.text == repeatNewPasswordField.text {
                Profile.shared.changePassword(oldPassword: currentPasswordField.text!, newPassword: newPasswordField.text!)
                print("Sent password change request!")
            }
        }
    }
    
    
}

class EditProfileCard : UIView {
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layer.cornerRadius = 15.0
    }
}
