//
//  ProfileCell.swift
//  XY_APP
//
//  Created by Maxime Franchot on 13/01/2021.
//

import UIKit

class ProfileCell: UITableViewCell, ProfileViewModelDelegate {

    static let identifier = "ProfileCell"
    
    var imagePickerDelegate: XYImagePickerDelegate?
    var imagePicker = UIImagePickerController()

    // MARK: - Properties
    
    var viewModel: ProfileViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    var isOwnProfile: Bool! {
        didSet {
            settingsButton.isHidden = !isOwnProfile
            editProfileButton.isHidden = !isOwnProfile
        }
    }
    
    func onProfileDataFetched(_ profileData: ProfileModel) {
        nicknameLabel.text = profileData.nickname
        xpCircle.levelLabel.text = String(describing: profileData.level)
        captionLabel.text = profileData.caption
        websiteLabel.text = profileData.website
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        profileImage.image = image
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileCard: UIView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var xynameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var xpCircle: CircleView!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    // MARK: - Delegate methods
    
    var onChatButtonPressed : (() -> Void)?
    var onFollowButtonPressed : (() -> Void)?
    var onSettingsButtonPressed : (() -> Void)?
    var onEditProfileButtonPressed : (() -> Void)?
    var onKeyboardDismiss : (() -> Void)?
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Display Properties
        followButton.layer.cornerRadius = 15
        followButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        followButton.layer.shadowRadius = 6
        
        chatButton.layer.cornerRadius = 15
        chatButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        chatButton.layer.shadowRadius = 6
        
        settingsButton.layer.cornerRadius = 5
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        settingsButton.layer.shadowRadius = 6
        
        editProfileButton.layer.cornerRadius = 5
        editProfileButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        editProfileButton.layer.shadowRadius = 6
        
        profileImage.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileImage.layer.shadowRadius = 6
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        // Display for Edit Properties
        editNicknameTextField.layer.borderWidth = 1
        editNicknameTextField.layer.borderColor = UIColor.white.cgColor
        editNicknameTextField.layer.cornerRadius = 5
        
        editCaptionTextField.layer.borderWidth = 1
        editCaptionTextField.layer.borderColor = UIColor.white.cgColor
        editCaptionTextField.layer.cornerRadius = 5
        
        editWebsiteTextField.layer.borderWidth = 1
        editWebsiteTextField.layer.borderColor = UIColor.white.cgColor
        editWebsiteTextField.layer.cornerRadius = 5
        
        editProfileImageButton.layer.opacity = 0.6
        editCoverImageButton.layer.opacity = 0.6
        
        coverImage.layer.cornerRadius = 10
        coverImage.backgroundColor = .clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - IBActions
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        onFollowButtonPressed?()
    }
    
    @IBAction func chatButtonPressed(_ sender: UIButton) {
        onChatButtonPressed?()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        editMode = true
        onEditProfileButtonPressed?()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        onSettingsButtonPressed?()
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        imagePickerDelegate?.presentImagePicker(imagePicker: imagePicker)
    }
    
    
    // MARK: - Edit Profile
    
    @IBOutlet weak var editNicknameTextField: UITextField!
    @IBOutlet weak var editCaptionTextField: UITextField!
    @IBOutlet weak var editWebsiteTextField: UITextField!
    
    @IBOutlet weak var editCoverImageButton: UIButton!
    @IBOutlet weak var editProfileImageButton: UIButton!
    
    var editMode: Bool = false {
        didSet {
            
            if editMode == oldValue { return }
            
            editNicknameTextField.isHidden = !editMode
            editCaptionTextField.isHidden = !editMode
            editWebsiteTextField.isHidden = !editMode
            editCoverImageButton.isHidden = !editMode
            editProfileImageButton.isHidden = !editMode
            
            nicknameLabel.isHidden = editMode
            captionLabel.isHidden = editMode
            websiteLabel.isHidden = editMode
            
            if editMode {
                // Enter editmode
                
                editNicknameTextField.text = nicknameLabel.text
                editCaptionTextField.text = captionLabel.text
                editWebsiteTextField.text = websiteLabel.text
                
                editNicknameTextField.sizeToFit()
                editCaptionTextField.sizeToFit()
                editWebsiteTextField.sizeToFit()
            } else {
                // Exit editmode
                
                nicknameLabel.text = editNicknameTextField.text
                captionLabel.text = editCaptionTextField.text
                websiteLabel.text = editWebsiteTextField.text
                
                nicknameLabel.sizeToFit()
                captionLabel.sizeToFit()
                websiteLabel.sizeToFit()
            }
        }
    }
    
    @objc func profilePictureTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Edit profile image!")
    }
    
    @IBAction func editFieldChanged(_ sender: UITextField) {
        // Resize to fit text
        sender.sizeToFit()
        sender.increaseSize(nil)
    }
    
    
    @IBAction func onEditNicknameEnded(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditCaptionEnded(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditWebsiteEnded(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditProfileImagePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func onEditCoverImagePressed(_ sender: UIButton) {
        
    }
    
    @objc func tappedAnywhere(tapGestureRecognizer: UITapGestureRecognizer) {
        editMode = false
        onKeyboardDismiss?()
    }
    
}

extension ProfileCell : UITextFieldDelegate {


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        textField.frame.size.width = textField.intrinsicContentSize.width + 15
//        textField.center.x = profViewContainer.center.x
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        textField.layer.borderColor = UIColor.blue.cgColor
//        // Hide Text field
//        let newText = textField.text!
//        textField.isHidden = true
//        profViewContainer.willRemoveSubview(textField)
//
//        var labelToEdit: UILabel? = nil
//
//        // Set Label text
//        if textField == editCaptionTextField {
//            labelToEdit = postCapt
//        } else if textField == editNicknameTextField {
//            labelToEdit = ProfNick
//        } else if textField == editWebsiteTextField {
//            labelToEdit = profileWebsite
//        }
//
//        // Update Label
//        labelToEdit!.text = newText
//        labelToEdit!.isHidden = false
//        labelToEdit!.layer.borderColor = UIColor.clear.cgColor
//
//        // Set data in viewmodel
//        if textField == editCaptionTextField {
//            viewModel?.profileData.caption = newText
//        } else if textField == editNicknameTextField {
//            viewModel?.profileData.nickname = newText
//        } else if textField == editWebsiteTextField {
//            viewModel?.profileData.website = newText
//        }
//
//        // Edit profile request: caption
//        if let profileData = viewModel?.profileData {
//            FirebaseUpload.editProfileInfo(profileData: profileData) { result in
//                switch result {
//                case .success():
//                    print("Successfully edited profile.")
//                case .failure(let error):
//                    print("Error editing profile caption: \(error)")
//                }
//            }
//        }
//    }
    }
}

extension ProfileCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // This is probably a bad way to do it, but for now the imagePreview image is where the image is stored.
            profileImage.image = image
            
            // Upload image and set profile data
            FirebaseUpload.uploadImage(image: image) { imageRef, error in
                if let error = error {
                    print("Error uploading new profile image: \(error)")
                }
                if let imageRef = imageRef, let viewModel = self.viewModel {
                    viewModel.profileData.imageId = imageRef
                    
                    FirebaseUpload.editProfileInfo(profileData: viewModel.profileData) { result in
                        switch result {
                        case .success():
                            print("Successfully uploaded and changed profile image")
                        case .failure(let error):
                            print("Error setting imageId for profile: \(error)")
                        }
                    }
                }
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
}


class EditImageButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -25, dy: -25).contains(point)
    }
}