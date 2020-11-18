//
//  ViewController.swift
//  XY_beta
//
//  Created by Maxime Franchot on 17/11/2020.
//

import Foundation
import SwiftUI
import UIKit

struct ViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewController>) -> ViewController.UIViewControllerType {
        
        let storyboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "Home")
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewController>) {
        
    }
    
}
