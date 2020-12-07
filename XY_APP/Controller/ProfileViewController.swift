//
//  ProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 03/12/2020.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker: UIImagePickerController
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var buttonsConsole: UIView!
    @IBOutlet weak var profileConteiner: UIView!
    @IBOutlet weak var coverPicture: UIImageView!
    
    @IBOutlet weak var editCoverImageButton: UIButton!
    @IBOutlet weak var editProfileImageButton: UIButton!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var xyNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Profile Model for this profile, contains info and methods needed to load from and upload to backend.
    var profile: Profile?
    
    required init(coder:NSCoder) {
        imagePicker = UIImagePickerController()

        super.init(coder: coder)!
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        // View own profile.
        setProfile(username: Current.sharedCurrentData.username)
    }
    
    func setProfile(username:String) {
        self.profile = Profile()
        profile?.username = username
        
        profile?.load(completion: {})
    }
    
    override func viewDidLoad() {
        coverPicture.layer.cornerRadius = 15.0
        
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
        
        let username = Current.sharedCurrentData.username
        
        // Load profile image
        Profile.getProfile(username: username, completion: {result in
            switch result {
            case .success(let profile):
                if let imageId = profile.profilePhotoId {
                    let imageManager = ImageManager()
                    imageManager.downloadImage(imageID: imageId, completion: { image in
                        if let image = image {
                            self.profileImage.image = image
                        }
                    })
                }
                if let imageId = profile.coverPhotoId {
                    let imageManager = ImageManager()
                    imageManager.downloadImage(imageID: imageId, completion: { image in
                        if let image = image {
                            self.coverPicture.image = image
                        }
                    })
                }
                //
                self.xyNameLabel.text = username
                if let location = profile.location {
                    self.locationLabel.text = location
                }
                if let aboutMe = profile.aboutMe {
                    self.descriptionLabel.text = aboutMe
                }
                if let fullName = profile.fullName {
                    self.fullNameLabel.text = fullName
                }
            case .failure(let error):
                print("Error getting profile photo!")
            }
        })
        
        super.viewDidLoad()
        
        // nav bar logo
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set profile image in app
            self.profile?.imagePickerHandler(newImage, completion: {result in
                switch result {
                case .success():
                    self.imagePicker.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error getting profile: ", error)
                    self.imagePicker.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func editProfileImagePresed(_ sender: UIButton) {
        print("EditProfileImagePressed")
        switch sender {
        case editProfileImageButton:
            profile?.setImageToEdit("profilePicture")
        case editCoverImageButton:
            profile?.setImageToEdit("coverPicture")
        default:
            break
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        print("imagePicker present!")
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setProfileImageImagePickerCompletion() {
        // Set new profile image
        let newProfileImage = UIImage(named:"profile")!
        // Upload the photo - save photo ID
        let imageManager = ImageManager()
        imageManager.uploadImage(image: newProfileImage, completionHandler: { result in
            print("Uploaded profile image with response: ", result.message)
            let imageId = result.id
            // Set profile to use this photo ID
            let editProfileRequest = Profile.EditProfileRequestMessage(profilePhotoId: imageId, coverPhotoId: nil, fullName: nil, location: nil, aboutMe: nil)
            Profile.sendEditProfileRequest(requestMessage: editProfileRequest, completion: {result in
                switch result {
                case .success(let message):
                    print("Successfully edited profile: ", message)
                    self.imagePicker.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error editing profile: ", error)
                    self.imagePicker.dismiss(animated: true, completion: nil)
                }
            })
        })
    }
}
