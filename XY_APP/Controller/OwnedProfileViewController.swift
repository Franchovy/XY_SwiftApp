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
        // Fallback if username is not right
        if username != Session.username {
            fatalError("Request to get someone else's profile using OwnedProfileViewController!")
        }
        
        self.profile = Profile()
        profile?.getProfile(username: username, closure: { result in
            switch result {
            case .success(let profileData):
                break
            case .failure(let error):
                print("Error loading profile: \(error)")
            }
            
        })
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
        
        if profile == nil {
            fatalError("Profile was not loaded! Please use loadProfile(username) before loading the ViewController")
        }
        
        let username = profile?.profileData?.username
        
        // Load profile image
        profile?.getProfile(username: username ?? Session.username, closure: {result in
            switch result {
            case .success(let profileData):
                //Load data into profileView
                
                // get image -> closure { switch : set profileimage or coverimage }
                self.xynameLabel.text = username
                
                if let location = profileData.location {
                    self.locationLabel.text = location
                }
                if let aboutMe = profileData.aboutMe {
                    self.captionLabel.text = aboutMe
                }
            case .failure(let error):
                print("Error getting profile photo: \(error)")
            }
        })
        
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set profile image in app
            imagePickerHandler(imageToSave: newImage, closure: { result in
                switch result {
                case .success(let imageId):
                    switch self.profile?.imagePickedType {
                    case .profilePicture:
                        DispatchQueue.main.async {
                            self.profileImage.image = newImage
                        }
                    case .coverPicture:
                        DispatchQueue.main.async {
                            self.coverPicture.image = newImage
                        }
                    case .mood:
                        fatalError("Hey, that feature isn't out yet!!")
                    case .post:
                        fatalError("Hey, that feature isn't out yet!!")
                    case .none:
                        fatalError("You need to set imagePickedType before calling the imagePickerHandler.")
                    }
                    self.imagePicker.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self.imagePicker.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    enum ImagePickerError:Error {
        case imageCacheProblem
        case editProfileProblem
        case connectionProblem
    }
    
    func imagePickerHandler (imageToSave:UIImage, closure: @escaping(Result<String, ImagePickerError>) -> Void) {
        // Upload the photo - save photo ID
        
        ImageCache.insertAndUpload(image: imageToSave, closure: { result in
            switch result {
            case .success(let imageId):
                // Send edit profile request
                let profilePictureId: String? = self.profile?.imagePickedType == .profilePicture ? imageId : nil
                let coverPictureId: String? = self.profile?.imagePickedType == .coverPicture ? imageId : nil
                let editProfileRequest = Profile.EditProfileData(profilePhotoId: profilePictureId, coverPhotoId: coverPictureId)
                
                self.profile?.editProfile(data: editProfileRequest, closure: {})
                
                closure(.success(imageId))
            case .failure(let error):
                if error == .connectionProblem {
                    closure(.failure(.connectionProblem))
                } else if error == .otherProblem {
                    closure(.failure(.imageCacheProblem))
                }
            }
        })
    }
    
    @IBAction func cameraNavigationBar(_ sender: UIBarButtonItem) {
        print("imagePicker present!")
        present(imagePicker, animated: true, completion: nil)
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
            profile?.imagePickedType = .profilePicture
        case editCoverImageButton:
            profile?.imagePickedType = .coverPicture
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



