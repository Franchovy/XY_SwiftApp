//
//  NavigationControlManager.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

final class NavigationControlManager {
    static var mainViewController: UIViewController!
    
    static func displayPrompt(_ prompt: Prompt) {
        mainViewController.navigationController?.view.addSubview(prompt)
        prompt.appear()
    }
    
    static func presentProfileViewController(with viewModel: ProfileViewModel) {
        let vc = ProfileViewController()
        vc.configure(with: viewModel)
        
        mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
        
    static func performLogout() {
        mainViewController.navigationController?.popToRootViewController(animated: true)
        
        let mainVC = AuthChoiceViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.navigationBar.backgroundColor = .clear
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 14.0, *) {
            navController.navigationItem.backButtonDisplayMode = .minimal
        }
        
        navController.heroModalAnimationType = .zoomSlide(direction: .left)
        
        mainViewController.dismiss(animated: true, completion: nil)
        mainViewController = mainVC
        
        if let window = UIApplication.shared.keyWindow {
            if let previousRootViewController = window.rootViewController {
                previousRootViewController.isHeroEnabled = true
                navController.isHeroEnabled = true
                previousRootViewController.heroReplaceViewController(with: navController)
                window.rootViewController = navController
            }
        }
    }
    
    static func performedAuthentication() {
        let mainVC = HomeViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.backgroundColor = UIColor(named: "XYBackground")
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Raleway-Bold", size: 20)!]
        navController.navigationBar.tintColor = UIColor(named: "XYTint")
        
        navController.heroModalAnimationType = .zoomSlide(direction: .left)
        navController.modalPresentationStyle = .fullScreen
        
        mainViewController = mainVC
        
        if let window = UIApplication.shared.keyWindow {
            mainVC.view.frame = window.bounds
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navController
            }, completion: nil)
        }
    }
}
