//
//  ProfileView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 15/12/2020.
//

import UIKit

class ProfileViewer {
    var parentViewController: UIViewController?
    
    func segueToProfile(username:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        
        profileVC.setProfile(username: username)
        
        if let parentViewController = parentViewController {
            parentViewController.show(profileVC, sender: parentViewController)
        } else {
            fatalError("Need to set the parent viewcontroller to self before calling!")
        }
    }
}
