//
//  ProfileUpperCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit
import Firebase

class ProfileUpperCell: UITableViewCell, ProfileViewModelDelegate {

    var viewModel: ProfileViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    // MARK: - ProfileViewModelDelegate functions
    
    func onProfileDataFetched(_ profileData: UpperProfile) {
        ProfNick.text = profileData.nickname
        profFollowers.text = String(describing: profileData.followers)
        profFollowing.text = String(describing: profileData.following)
        profLev.text = String(describing: profileData.level)
        postCapt.text = profileData.caption
        profileWebsite.text = profileData.website
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        ProfImg.image = image
    }
    
    //MARK: - Delegate functions
    
    var logout: (() -> Void)?
    var chatSegue: (() -> Void)?
    
    @objc func tappedAnywhere(tapGestureRecognizer: UITapGestureRecognizer) {
        // End text field editing if ongoing
        if editCaptionTextField != nil {
            editCaptionTextField?.endEditing(true)
            editCaptionTextField = nil
        } else if editNicknameTextField != nil {
            editNicknameTextField?.endEditing(true)
            editNicknameTextField = nil
        } else if editWebsiteTextField != nil {
            editWebsiteTextField?.endEditing(true)
            editWebsiteTextField = nil
        }
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var profLev: UILabel!
    @IBOutlet weak var profViewContainer: UIView!
    @IBOutlet weak var profileWebsite: UILabel!
    
    @IBOutlet weak var captionContainer: UIView!
    @IBOutlet weak var coverImage: UIImageView!

    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
        
    // Editable
    @IBOutlet weak var ProfImg: UIImageView!
    @IBOutlet weak var ProfNick: UILabel!
    @IBOutlet weak var postCapt: UILabel!
    
    var editNicknameTextField: UITextField? = nil
    var editCaptionTextField: UITextField? = nil
    var editWebsiteTextField: UITextField? = nil
    
    @IBOutlet weak var levelView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        ProfImg.isUserInteractionEnabled = false
        ProfImg.addGestureRecognizer(tapGestureRecognizer)

        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(editLabel(tapGestureRecognizer:)))
        postCapt.isUserInteractionEnabled = false
        postCapt.addGestureRecognizer(tapGestureRecognizer2)

        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(editLabel(tapGestureRecognizer:)))
        ProfNick.isUserInteractionEnabled = false
        ProfNick.addGestureRecognizer(tapGestureRecognizer3)

        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(editLabel(tapGestureRecognizer:)))
        profileWebsite.isUserInteractionEnabled = false
        profileWebsite.addGestureRecognizer(tapGestureRecognizer4)

        ProfImg.layer.cornerRadius = 10
        coverImage.layer.cornerRadius = 15
        profViewContainer.layer.cornerRadius = 15
        captionContainer.layer.cornerRadius = 15
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.shake()

    }

    @objc func editLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        var label = tapGestureRecognizer.view as! UILabel

        // Create and set textfield
        var textField = UITextField(frame: label.frame)
        textField.text = label.text

        textField.frame.size.width = textField.intrinsicContentSize.width + 15
        textField.center.x = profViewContainer.center.x

        profViewContainer.addSubview(textField)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.textColor = .white
        textField.layer.cornerRadius = 5

        textField.becomeFirstResponder()
        textField.delegate = self
        
        label.isHidden = true
        if label == postCapt {
            editCaptionTextField = textField
        } else if label == ProfNick {
            editNicknameTextField = textField
        } else if label == profileWebsite {
            editWebsiteTextField = textField
        }
    }
        
    // LOGOUT
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout?()
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
    }

    // CHATS
    @IBAction func chatButtonPressed(_ sender: Any) {
        chatSegue?()
    }
   
    @IBAction func editButtonPressed(_ sender: UIButton) {
       
        ProfImg.layer.borderColor = UIColor.systemPink.cgColor
        ProfImg.layer.borderWidth = 1
        ProfImg.shake()
        ProfImg.isUserInteractionEnabled = true

        postCapt.shake()
        postCapt.layer.borderWidth = 1
        postCapt.layer.borderColor = UIColor.white.cgColor
        postCapt.isUserInteractionEnabled = true

        ProfNick.shake()
        ProfNick.layer.borderWidth = 1
        ProfNick.layer.borderColor = UIColor.white.cgColor
        ProfNick.isUserInteractionEnabled = true
        
        profileWebsite.shake()
        profileWebsite.layer.borderWidth = 1
        profileWebsite.layer.borderColor = UIColor.white.cgColor
        profileWebsite.isUserInteractionEnabled = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

extension ProfileUpperCell : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension ProfileUpperCell : UITextFieldDelegate {


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.frame.size.width = textField.intrinsicContentSize.width + 15
        textField.center.x = profViewContainer.center.x
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderColor = UIColor.blue.cgColor
        // Hide Text field
        let newText = textField.text!
        textField.isHidden = true
        profViewContainer.willRemoveSubview(textField)
        
        var labelToEdit: UILabel? = nil
        
        // Set Label text
        if textField == editCaptionTextField {
            labelToEdit = postCapt
        } else if textField == editNicknameTextField {
            labelToEdit = ProfNick
        } else if textField == editWebsiteTextField {
            labelToEdit = profileWebsite
        }
        
        // Update Label
        labelToEdit!.text = newText
        labelToEdit!.isHidden = false
        labelToEdit!.layer.borderColor = UIColor.clear.cgColor
        
        // Set data in viewmodel
        if textField == editCaptionTextField {
            viewModel?.profileData.caption = newText
        } else if textField == editNicknameTextField {
            viewModel?.profileData.nickname = newText
        } else if textField == editWebsiteTextField {
            viewModel?.profileData.website = newText
        }
        
        // Edit profile request: caption
        if let profileData = viewModel?.profileData {
            FirebaseUpload.editProfileInfo(profileData: profileData) { result in
                switch result {
                case .success():
                    print("Successfully edited profile.")
                case .failure(let error):
                    print("Error editing profile caption: \(error)")
                }
            }
        }
    }
}

public extension UILabel {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.5,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

public extension UIImageView {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.5,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}


public extension UIButton {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.5,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}
