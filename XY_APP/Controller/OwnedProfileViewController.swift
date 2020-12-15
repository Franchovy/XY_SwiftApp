//
//  ownedProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 12/12/2020.
//

import Foundation
import UIKit

class OwnedProfileViewController :  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate  {
    
    var imagePicker: UIImagePickerController
    
    @IBOutlet weak var editCoverImageButton: UIButton!
    @IBOutlet weak var editProfilePictureButton: UIButton!
    @IBOutlet weak var coverPicture: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var moodView: UIView!
    @IBOutlet weak var buttonConsole: UIView!
    @IBOutlet weak var xynameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    
    var profile: Profile?
    
    required init(coder:NSCoder) {
        imagePicker = UIImagePickerController()
        
        super.init(coder: coder)!
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        // View own profile.
        setProfile(username: Session.username)
    }
    
    
    
    func setProfile(username:String) {
        self.profile = Profile()
        
        profile?.loadFrom(username: username, completion: {})
    }
    
    override func viewDidLoad() {
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        profileContainer.layer.cornerRadius = 15.0
        profileContainer.layer.shadowColor = UIColor.black.cgColor
        profileContainer.layer.shadowOffset = CGSize(width:1, height:1)
        profileContainer.layer.shadowRadius = 1
        profileContainer.layer.shadowOpacity = 1.0
        
        moodView.layer.cornerRadius = 15.0
        moodView.layer.shadowColor = UIColor.black.cgColor
        moodView.layer.shadowOffset = CGSize(width:1, height:1)
        moodView.layer.shadowRadius = 1
        moodView.layer.shadowOpacity = 1.0
        
        buttonConsole.layer.cornerRadius = 15.0
        buttonConsole.layer.shadowColor = UIColor.black.cgColor
        buttonConsole.layer.shadowOffset = CGSize(width:1, height:1)
        buttonConsole.layer.shadowRadius = 1
        buttonConsole.layer.shadowOpacity = 1.0
        
        let username = profile?.username
        
        // Load profile image
        Profile.getProfile(username: username ?? Session.username, completion: {result in
            switch result {
            case .success(let profile):
                if let imageId = profile.profilePhotoId {
                    
                    ImageManager.downloadImage(imageID: imageId, completion: { image in
                        if let image = image {
                            self.profileImage.image = image
                        }
                    })
                }
                if let imageId = profile.coverPhotoId {
                    
                    ImageManager.downloadImage(imageID: imageId, completion: { image in
                        if let image = image {
                            self.coverPicture.image = image
                        }
                    })
                }
                //
                self.xynameLabel.text = username
                if let location = profile.location {
                    self.locationLabel.text = location
                }
                if let aboutMe = profile.aboutMe {
                    self.captionLabel.text = aboutMe
                }
            case .failure(let error):
                print("Error getting profile photo!")
            }
        })
        
        
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Does this print?")
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set profile image in app
            self.profile?.imagePickerHandler(newImage, completion: { result in
                switch result {
                case .success():
                    switch self.profile?.imageToEdit {
                    case "coverPicture":
                        self.coverPicture.image = newImage
                    case "profilePicture":
                        self.profileImage.image = newImage
                    default:
                        fatalError("Error, no picture being edited. Fix this")
                    }
                    self.imagePicker.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error getting profile: ", error)
                    self.imagePicker.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func cameraNavigationBar(_ sender: UIBarButtonItem) {
        print("imagePicker present!")
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setProfileImageImagePickerCompletion() {
        // Set new profile image
        let newProfileImage = UIImage(named:"profile")!
        // Upload the photo - save photo ID
        
        ImageManager.uploadImage(image: newProfileImage, completionHandler: { result in
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
    @IBAction func postButton(_ sender: UIButton) {
    }
    
    @IBAction func friendsButton(_ sender: UIButton) {
    }
    @IBAction func settingsButton(_ sender: UIButton) {
    }
    
    @IBAction func editCoverImageButton(_ sender: UIButton) {
    }
    
    @IBAction func editProfilePictureButton(_ sender: UIButton) {
        print("EditProfileImagePressed")
        switch sender {
        case editProfilePictureButton:
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
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        Auth.logout(completion: { result in
            switch result {
            case .success:
                // Segue to login
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:UIViewController
                
                if #available(iOS 13.0, *) {
                    vc = storyboard.instantiateViewController(identifier: "LoginViewController")
                } else {
                    // Fallback on earlier versions
                    vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                }

                // Hide Top and Bottom navigation bars!
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.navigationBar.isHidden = true
                // Show next viewcontroller
                self.show(vc, sender: self)
            case .failure:
                print("Error logging out from backend!")
                
                // Force local logout.
                Auth.forceLogout()
            }
        })
    }
}



