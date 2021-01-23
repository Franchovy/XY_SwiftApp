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
        
        cameraView.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "createPost_newIcon"), tag: 3)
        viewControllers?[2] = cameraView
        
        cameraView.delegate = self
        self.cameraView = cameraView
        
    }
    
}

extension TabBarViewController: CameraViewControllerDelegate {
    func cameraViewDidTapCloseButton() {
        selectedIndex = 0
        setTabBarVisible(visible: true, duration: 0.1, animated: true)
    }
}
