//
//  TabBarViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    static var instance: TabBarViewController!
    
    var onInitFinished: (() -> Void)?
    var eyesMode = false
    
    var playVC: PlayViewController!
    var cameraVC: CameraViewController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        TabBarViewController.instance = self
        
        guard let userId = AuthManager.shared.userId else { return }
        setProfileIcon(userID: userId)
        
        isHeroEnabled = true
        heroTabBarAnimationType = .auto
        
        PushNotificationManager.shared?.tabBarController = self
        ProfileManager.shared.delegate = self
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "Raleway-Heavy", size: 10)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
        tabBar.isTranslucent = false
        
        playVC = PlayViewController()
        cameraVC = CameraViewController()
        
        let nav1 = UINavigationController(
            rootViewController: playVC
        )
        let nav2 = UINavigationController(
            rootViewController: ExploreVC()
        )
        let nav3 = UINavigationController(
            rootViewController: cameraVC
        )
        let nav4 = UINavigationController(
            rootViewController: XYworldVC()
        )
        let nav5 = UINavigationController(
            rootViewController: NewProfileViewController(userId: userId)
        )
        setViewControllers([nav1, nav2, nav3, nav4, nav5], animated: false)
        
        eyesMode = Int.random(in: 0...50) == 1
        let icon = eyesMode ? UIImage(systemName: "eyes") : UIImage(named: "tabbar_watch_icon-1")
        nav1.tabBarItem = UITabBarItem(
            title: "Watch",
            image: icon,
            tag: 1
        )
        tabBar.tintColor = UIColor(named: "XYTint")
        nav2.tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(named: "tabbar_challenges_icon"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_play_icon")!.withRenderingMode(.alwaysOriginal), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "XYHub", image: UIImage(named: "tabbar_xyworld_icon"), tag: 4)
        
        nav1.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        nav1.tabBarItem.imageInsets.top = 3
        nav2.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        nav2.tabBarItem.imageInsets.top = 7
        nav3.tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: -18, bottom: -18, right: -18)
        nav4.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        nav4.tabBarItem.imageInsets.top = 3
        nav5.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        nav5.tabBarItem.imageInsets.top = 3
        
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
        
        view.layoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

    }
    
    public func popupPrompt(title: String, message: String, confirmText: String, completion: @escaping(() -> Void)) {
        // Add blur
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.0
        view.addSubview(blurEffectView)
        
        UIView.animate(withDuration: 0.2) {
            blurEffectView.alpha = 1.0
        } completion: { (done) in
            if done {
                // Add popup View
                let popupView = PopupMessageView(
                    title: title,
                    message: message,
                    type: .message(confirmText: confirmText),
                    completion: {
                        UIView.animate(withDuration: 0.2) {
                            blurEffectView.alpha = 0.0
                        } completion: { (done) in
                            if done {
                                blurEffectView.removeFromSuperview()
                            }
                        }
                        
                        completion()
                    }
                )
                
                popupView.sizeToFit()
                self.view.addSubview(popupView)
                popupView.center = self.view.center
            }
        }
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
        
        if let profileImage = ProfileManager.shared.loadProfileImageFromFile() {
            loadProfileImageToTabBar(image: profileImage)
        } else {
            
            StorageManager.shared.downloadImage(withImageId: ownProfile.profileImageId) { (image, error) in
                if let error = error {
                    print(error)
                } else if let image = image {
                    self.loadProfileImageToTabBar(image: image)
                    
                    ProfileManager.shared.saveProfileImageToFile(image: image)
                }
            }
        }
    }
    
    private func loadProfileImageToTabBar(image: UIImage) {
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
        profileTabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        profileTabBarItem.imageInsets.top = 3
        
        guard let profileVC = self.viewControllers?[4] else {
            return
        }
        
        profileVC.tabBarItem = profileTabBarItem
        
        self.onInitFinished?()
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
            
            cameraView.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        }
    }
    
    public func backToLaunch() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = mainStoryboard.instantiateViewController(identifier: "LaunchVC")
        vc.modalPresentationStyle = .fullScreen
        show(vc, sender: self)
    }
    
    public func playChallenge(challenge: ChallengeViewModel) {
        selectedIndex = 0
        
        playVC.configure(for: challenge)
    }
    
    public func startChallenge(challenge: ChallengeViewModel) {
        selectedIndex = 2
        
        cameraVC.pressedPlay(challenge: challenge)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if tabBar.selectedItem == item {
//            if let itemIndex = tabBar.items?.firstIndex(of: item), let viewController = viewControllers?[itemIndex] {
//                navigationController?.popToViewController(viewController, animated: true)
//            }
//        }
        
        if eyesMode {
            if tabBar.items?[0] == item {
                tabBar.items?[0].image = UIImage(systemName: "eyes")
            } else {
                tabBar.items?[0].image = UIImage(cgImage: UIImage(systemName: "eyes")!.cgImage!,
                                                 scale: 2.0, orientation: UIImage.Orientation.upMirrored)
            }
        }
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
        
    }
    
    func cameraViewDidTapCloseButton() {
        selectedIndex = 0
        //        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }
    
}
