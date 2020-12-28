//
//  OtherProfileViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 15/12/2020.
//

import UIKit

class OtherProfileViewController :  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate  {
    
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
        
    }
    
    func loadProfileForUser(username:String) {
        self.profile = Profile()
        
        profile?.getProfile(username: username, closure: { result in
            switch result {
            case .success(let profileData):
                // Load properties into profile view
                DispatchQueue.main.async {
                    self.xynameLabel.text = profileData.username
                    self.locationLabel.text = profileData.location
                    self.captionLabel.text = profileData.caption
                    
                    if let profileImageId = profileData.profilePhotoId {
                        ImageCache.createOrQueueImageRequest(id: profileImageId, completion: { image in
                            if let image = image {
                                self.profileImage.image = image
                            }
                        })
                    }
                    if let coverImageId = profileData.coverPhotoId {
                        ImageCache.createOrQueueImageRequest(id: coverImageId, completion: { image in
                            if let image = image {
                                self.coverPicture.image = image
                            }
                        })
                    }
                }
            case .failure(let error):
                print("Error getting profile: \(error)")
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
        
        
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
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
}



