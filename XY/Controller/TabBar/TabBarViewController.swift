//
//  TabBarViewController.swift
//  XY
//
//  Created by Maxime Franchot on 22/01/2021.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    private var cameraView: CameraViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraView = CameraViewController()
        
        cameraView.setCloseButtonVisible(false)
        
        viewControllers?[2] = cameraView
        
        cameraView.delegate = self
        self.cameraView = cameraView
        
        setCreatePostIcon()
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
        }
    }
}

extension TabBarViewController: CameraViewControllerDelegate {
    func cameraViewDidTapCloseButton() {
        selectedIndex = 0
        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }
}
