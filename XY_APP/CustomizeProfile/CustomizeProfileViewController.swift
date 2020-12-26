//
//  CustomizeProfileViewController.swift
//  XY_APP
//
//  Created by Simone on 29/11/2020.
//

import UIKit


class CustomizeProfileViewController: UIViewController{
    @IBOutlet weak var progileImageView: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var captionContainerView: UIView!
    
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
            case .failure(let error):
                print("Error getting profile data: \(error)")
            }
        })
        
        progileImageView.layer.cornerRadius = 15.0
        detailsContainerView.layer.cornerRadius = 15.0
        captionContainerView.layer.cornerRadius = 15.0
    }
    
    
}
