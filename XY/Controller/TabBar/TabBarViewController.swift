//
//  TabBarViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var onInitFinished: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        guard let userId = AuthManager.shared.userId else { return }
        setProfileIcon(userID: userId)
        
        isHeroEnabled = true
        heroTabBarAnimationType = .auto

        PushNotificationManager.shared?.tabBarController = self
        ProfileManager.shared.delegate = self
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "Raleway-Heavy", size: 15)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
        let nav1 = UINavigationController(
            rootViewController: PlayViewController()
        )
        let nav2 = UINavigationController(
            rootViewController: ExploreVC()
        )
        let nav3 = UINavigationController(
            rootViewController: CameraViewController()
        )
        let nav4 = UINavigationController(
            rootViewController: XYworldVC()
        )
        let nav5 = UINavigationController(
            rootViewController: NewProfileViewController(userId: userId)
        )
        setViewControllers([nav1, nav2, nav3, nav4, nav5], animated: false)
        
        nav1.tabBarItem = UITabBarItem(title: "Watch", image: UIImage(named: "tabbar_watch_icon"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(named: "tabbar_challenges_icon"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_play_icon")!.withRenderingMode(.alwaysOriginal), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "XYWorld", image: UIImage(named: "tabbar_xyworld_icon"), tag: 4)
        
        nav3.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: -6, bottom: -6, right: -6)
        
        nav2.tabBarItem.imageInsets.top = 5
        
        guard let cameraVC = viewControllers?[2] as? CameraViewController else {
            return
        }
        cameraVC.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let ownProfile = ProfileManager.shared.ownProfile else {
            ProfileManager.shared.onInitFinished = {
                self.setUpProfileTabBarItem()
            }
            return
        }
        
        setUpProfileTabBarItem()
    }
    
    private func setUpProfileTabBarItem() {
        guard let ownProfile = ProfileManager.shared.ownProfile else {
            fatalError()
        }
        
        StorageManager.shared.downloadImage(withImageId: ownProfile.profileImageId) { (image, error) in
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
                
                guard let profileVC = self.viewControllers?[4] else {
                    return
                }
                
                profileVC.tabBarItem = profileTabBarItem
                
                self.onInitFinished?()
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
                profileVC.heroModalAnimationType = .pageIn(direction: .left)
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
