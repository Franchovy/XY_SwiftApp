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
        
        isHeroEnabled = true
        heroModalAnimationType = .zoomSlide(direction: .right)

        PushNotificationManager.shared?.tabBarController = self
        ProfileManager.shared.delegate = self
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "Raleway-Heavy", size: 15)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
        // TAB 1: PLAY VC
        let flowVC = viewControllers![0]
        flowVC.tabBarItem = UITabBarItem(title: "Play", image: UIImage(named: "tabbar_play_icon"), tag: 1)
        
        
        // TAB 2: EXPLORE VC
        let exploreVC = ExploreVC()
        let tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(named: "tabbar_challenges_icon"), tag: 2)
        tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        tabBarItem.badgeColor = UIColor(named: "tintColor")
        exploreVC.tabBarItem = tabBarItem
        
        viewControllers?[1] = exploreVC
        self.exploreVC = exploreVC
        
        // TAB 3: CAMERA VC
        let cameraVC = CameraViewController()
        let cameraTabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.circle.fill"), tag: 3)
        cameraVC.tabBarItem = cameraTabBarItem
        viewControllers?[2] = cameraVC
        cameraVC.delegate = self
        self.cameraVC = cameraVC
        
        // TAB 5: PROFILE VC
        guard let userId = AuthManager.shared.userId else { return }
        setProfileIcon(userID: userId)
        
//        let profileVC = ProfileViewController(userId: userId)
        let profilevc = NewProfileViewController(userId: userId)
        let profileVC = UINavigationController(rootViewController: profilevc)
        
        viewControllers?[4] = profileVC
        
        self.profileVC = profilevc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tabBar.isHidden = false
        view.layoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setCreatePostIcon()
    }
    
    private func setProfileIcon(userID: String) {
        ProfileFirestoreManager.shared.getProfileID(forUserID: userID) { (profileID, error) in
            if let error = error {
                print(error)
            } else if let profileID = profileID {
                ProfileFirestoreManager.shared.getProfile(
                    forProfileID: profileID) { (profileModel) in
                    if let profileModel = profileModel {
                        StorageManager.shared.downloadImage(withImageId: profileModel.profileImageId) { (image, error) in
                            if let error = error {
                                print(error)
                            } else if let image = image {
                                let imageView = UIImageView()
                                imageView.image = image
                                imageView.frame.size = CGSize(width: 29, height: 29)
                                imageView.layer.masksToBounds = true
                                imageView.layer.borderWidth = 1
                                imageView.layer.borderColor = UIColor.white.cgColor
                                imageView.layer.cornerRadius = 29 / 2
                                let tabbarProfileIcon = imageView.asImage().withRenderingMode(.alwaysOriginal)
                                
                                let profileTabBarItem = UITabBarItem(title: "Profile", image: tabbarProfileIcon, tag: 5)
                                profileTabBarItem.badgeColor = UIColor(named: "tintColor")

                                self.profileVC?.tabBarItem = profileTabBarItem
                            }
                        }
                    }
                }
            }
        }
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
        
        if profileId == ProfileManager.shared.ownProfileId {
            selectedIndex = 4
        } else {
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
//        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }

}
