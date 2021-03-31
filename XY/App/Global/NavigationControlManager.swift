//
//  NavigationControlManager.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

final class NavigationControlManager {
    static var mainViewController: UIViewController!
    
    static func presentProfileViewController(with viewModel: ProfileViewModel) {
        let vc = ProfileViewController()
        vc.configure(with: viewModel)
        
        mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
}
