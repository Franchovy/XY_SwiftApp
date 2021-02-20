//
//  TabBarViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit

class TabBarViewController: UITabBarController {
        
    private var exploreVC: ExploreVC?
    private var cameraVC: CameraViewController?
    private var profileVC: NewProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PushNotificationManager.shared?.tabBarController = self
        ProfileManager.shared.delegate = self
        
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
        guard let userId = AuthManager.shared.userId else { return }
        
//        let profileVC = ProfileViewController(userId: userId)
        let profilevc = NewProfileViewController(userId: userId)
        let profileVC = UINavigationController(rootViewController: profilevc)
        
        let profileTabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile_item"), tag: 5)
        profileTabBarItem.badgeColor = UIColor(named: "tintColor")

        profileVC.tabBarItem = profileTabBarItem
        viewControllers?[4] = profileVC
        
        self.profileVC = profilevc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBar.isHidden = false
        view.layoutSubviews()
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
    
    public func backToLaunch() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = mainStoryboard.instantiateViewController(identifier: "LaunchVC")
        vc.modalPresentationStyle = .fullScreen
        show(vc, sender: self)
    }
}

extension TabBarViewController {
    func pushChatVC(chatVC: ProfileHeaderChatViewController) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension TabBarViewController: ProfileManagerDelegate {
    func profileManager(openProfileFor profileId: String) {
        FirebaseDownload.getOwnerUser(forProfileId: profileId) { userId, error in
            guard let userId = userId, error == nil else {
                print("Error fetching profile with id: \(profileId)")
                print(error)
                return
            }
            
            let profileVC = NewProfileViewController(userId: userId)
            profileVC.modalPresentationStyle = .fullScreen
            self.navigationController?.isNavigationBarHidden = false
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

extension TabBarViewController: CameraViewControllerDelegate {
    func didFinishUploadingPost(postData: PostViewModel) {
        selectedIndex = 0
        
        viewControllers?.forEach({ print($0) })
        
        guard let flowNavigationVC = self.viewControllers?[0] as? UINavigationController,
              let flowVC = flowNavigationVC.children.first as? FlowVC else {
            return
        }
        
//        flowVC.insertPost(postData)
    }
    
    func cameraViewDidTapCloseButton() {
        selectedIndex = 0
        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }
}
