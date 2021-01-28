//
//  TabBarViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit
import FirebaseAuth

class TabBarViewController: UITabBarController {
    
    private var exploreVC: ExploreVC?
    private var cameraVC: CameraViewController?
    private var profileVC: ProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TAB 2: EXPLORE VC
        let exploreVC = ExploreVC()
        let tabBarItem = UITabBarItem(title: "Viral", image: UIImage(named: "viral_item"), tag: 2)
        tabBarItem.badgeColor = UIColor(named: "tintColor")
        exploreVC.tabBarItem = tabBarItem
        
        viewControllers?[1] = exploreVC
        self.exploreVC = exploreVC
        
        
        // TAB 3: CAMERA VC
        let cameraVC = CameraViewController()
        viewControllers?[2] = cameraVC
        cameraVC.delegate = self
        self.cameraVC = cameraVC
        
        setCreatePostIcon()
        
        // TAB 5: PROFILE VC
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let profileVC = ProfileViewController(userId: uid)
        let profileTabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile_item"), tag: 5)
        profileTabBarItem.badgeColor = UIColor(named: "tintColor")
        
        let profileNavigator = UINavigationController(rootViewController: profileVC)

        profileNavigator.tabBarItem = profileTabBarItem
        viewControllers?[4] = profileNavigator
        
        self.profileVC = profileVC
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setCreatePostIcon()
    }
    
    private func setCreatePostIcon() {
        guard let cameraView = viewControllers?[2] else {
            return
        }
        DispatchQueue.main.async {
            if self.traitCollection.userInterfaceStyle == .light {
                cameraView.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(named: "createpost_newIcon_light")?.withRenderingMode(.alwaysOriginal),
                    tag: 3
                )
            } else {
                cameraView.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(named: "createpost_newIcon_dark")?.withRenderingMode(.alwaysOriginal),
                    tag: 3
                )
            }
            cameraView.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: -5, right: -5)
        }
    }
}

extension TabBarViewController: CameraViewControllerDelegate {
    func cameraViewDidTapCloseButton() {
        selectedIndex = 0
        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }
}
