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
        ProfNick.text = profileData.xyname
        profFollowers.text = String(describing: profileData.followers)
        profFollowing.text = String(describing: profileData.following)
        profLev.text = String(describing: profileData.level)
        postCapt.text = profileData.caption
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        ProfImg.image = image
    }
    
    //MARK: - Delegate functions
    
    var logout: (() -> Void)?
    var chatSegue: (() -> Void)?

    
    //MARK: - IBOutlets
    
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var profLev: UILabel!
    @IBOutlet weak var profViewContainer: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    // Editable
    @IBOutlet weak var ProfImg: UIImageView!
    @IBOutlet weak var ProfNick: UILabel!
    @IBOutlet weak var postCapt: UILabel!
    
    var editNicknameTextField: UITextField? = nil
    var editCaptionTextField: UITextField? = nil
    
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
        
        
        ProfImg.layer.cornerRadius = 10
        profViewContainer.layer.cornerRadius = 15.0
        followersView.layer.cornerRadius = 10.0
        followingView.layer.cornerRadius = 10.0
        
        levelView.layer.cornerRadius = 10.0
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.shake()
        
    }
    
    @objc func editLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        var label = tapGestureRecognizer.view as! UILabel
        
        // Create and set textfield
        var textField = UITextField(frame: label.frame)
        profViewContainer.addSubview(textField)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.textColor = .systemPink
        textField.layer.cornerRadius = 5
        
        label.isHidden = true
        if label == postCapt {
            editCaptionTextField = textField
        
        } else if label == ProfNick {
            editNicknameTextField = textField
            
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        logout?()
    }
    
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        chatSegue?()
    }
   
    @IBAction func editButtonPressed(_ sender: UIButton) {
       
        ProfImg.layer.borderColor = UIColor.systemPink.cgColor
        ProfImg.layer.borderWidth = 3
        ProfImg.isUserInteractionEnabled = true
        
        postCapt.textColor = UIColor.systemPink
        postCapt.isUserInteractionEnabled = true
        
        ProfNick.textColor = UIColor.systemPink
        ProfNick.isUserInteractionEnabled = true
        
        
        
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
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
    }
}

public extension UITextField {

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


