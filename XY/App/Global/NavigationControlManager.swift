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
    
    static func startChallenge(with viewModel: ChallengeCardViewModel) {
        let vc = AcceptChallengeViewController(viewModel: viewModel)
        CreateChallengeManager.shared.loadAcceptedChallenge(viewModel)
        
        mainViewController.hero.modalAnimationType = .zoomSlide(direction: .right)
        mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func presentProfileViewController(with viewModel: UserViewModel) {
        let vc = ProfileViewController()
        vc.configure(with: viewModel)
        
        mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func backToCamera() {
        if let cameraVC = mainViewController.navigationController?.viewControllers.first(
            where: {$0 is CreateChallengeViewController || $0 is AcceptChallengeViewController}) {
            mainViewController.navigationController?.popToViewController(cameraVC, animated: true)
        } else {
            mainViewController.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    static func backToHome() {
        mainViewController.navigationController?.popToRootViewController(animated: true)
    }
    
    static func performLogout() {
        let mainVC = AuthChoiceViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.navigationBar.backgroundColor = .clear
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 14.0, *) {
            navController.navigationItem.backButtonDisplayMode = .minimal
        }
        
        mainViewController = mainVC
        
        let window = UIApplication.shared.windows[0]
        if let previousRootViewController = window.rootViewController {
            window.rootViewController = navController
            previousRootViewController.navigationController?.popToRootViewController(animated: true)
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
        
        let previousMainViewController = mainViewController
        mainViewController = mainVC
        
        let window = UIApplication.shared.windows[0]
        mainVC.view.frame = window.bounds
        
        window.rootViewController = navController
        previousMainViewController?.navigationController?.popToRootViewController(animated: true)
    }
}
