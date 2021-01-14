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
    
    var viewModel: ProfileViewModel? {
        didSet {
            viewModel?.delegate = self
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
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var xynameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var xpCircle: CircleView!
    
    @IBOutlet weak var followButton: UIButton!
//    @IBOutlet weak var chatButton: UIImageView!
    
    // MARK: - Delegate methods
    
    var onChatButtonPressed : (() -> Void)?
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        followButton.layer.cornerRadius = 15
//        followButton.layer.shadowOffset = CGSize(width: 0, height: 4)
//        followButton.layer.shadowRadius = 8
        
//        chatButton.layer.cornerRadius = 15
//        chatButton.layer.shadowOffset = CGSize(width: 0, height: 4)
//        chatButton.layer.shadowRadius = 8
        
        profileImage.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileImage.layer.shadowRadius = 8
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        coverImage.layer.cornerRadius = 10
        coverImage.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: -
    @IBAction func chatButtonPressed(_ sender: Any) {
        onChatButtonPressed?()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        imagePickerDelegate?.presentImagePicker(imagePicker: imagePicker)
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
