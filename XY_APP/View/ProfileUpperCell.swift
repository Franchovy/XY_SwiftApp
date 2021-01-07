//
//  ProfileUpperCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit
import Firebase

class ProfileUpperCell: UITableViewCell {
    
    //MARK: - Delegate functions
    
    var logout: (() -> Void)?
    var chatSegue: (() -> Void)?

    
    //MARK: - IBOutlets
    
    @IBOutlet weak var ProfImg: UIImageView!
    @IBOutlet weak var ProfNick: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var profLev: UILabel!
    @IBOutlet weak var postCapt: UILabel!
    @IBOutlet weak var profViewContainer: UIView!
    
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var levelView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
  
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        ProfImg.isUserInteractionEnabled = false
        ProfImg.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(labelTapped(tapGestureRecognizer:)))
        postCapt.isUserInteractionEnabled = false
        postCapt.addGestureRecognizer(tapGestureRecognizer2)
        
        
        ProfImg.layer.cornerRadius = 10
        profViewContainer.layer.cornerRadius = 15.0
        followersView.layer.cornerRadius = 10.0
        followingView.layer.cornerRadius = 10.0
        
        levelView.layer.cornerRadius = 10.0
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

    }
    
    @objc func labelTapped(tapGestureRecognizer: UITapGestureRecognizer)
    
    {
        let tappedLabel = tapGestureRecognizer.view as! UILabel
        let textField = UITextField(frame: tappedLabel.frame)
        profViewContainer.addSubview(textField)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.textColor = .systemPink
        textField.layer.cornerRadius = 5
        tappedLabel.isHidden = true

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





